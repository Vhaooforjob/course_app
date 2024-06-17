import 'package:course_app/pages/course_detail_page.dart';
import 'package:course_app/pages/user_detail_page.dart';
import 'package:course_app/services/api_search_services.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  bool _noResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _noResults = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _noResults = false;
    });

    try {
      final data = await APISearchServices.searchQuery(query);
      if (mounted) {
        setState(() {
          _searchResults = data['users'] + data['courses'];
          _isLoading = false;
          _noResults = _searchResults.isEmpty;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _noResults = true;
        });
      }
      print(e);
    }
  }

  // void _navigateToUserDetail(String userId) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => UserDetailPage(userId: userId)),
  //   );
  // }

  void _navigateToCourseDetail(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CourseDetailPage(courseId: courseId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _search(_searchController.text);
              },
            ),
          ),
          onSubmitted: (value) {
            _search(value);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _noResults
              ? const Center(
                  child: Text('Không tìm thấy kết quả tương ứng'),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    final imageUrl = result['image_url'] ?? '';
                    Widget leadingWidget;
                    if (result.containsKey('full_name')) {
                      // Người dùng
                      leadingWidget = imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(Icons.account_circle,
                                  color: Colors.grey),
                            );

                      return ListTile(
                        leading: leadingWidget,
                        title: Text(result['full_name']),
                        subtitle: Text(result['email'] ?? ''),
                        // onTap: () => _navigateToUserDetail(result['_id']),
                      );
                    } else {
                      // Khóa học
                      final createdBy =
                          result['user_id']['full_name'] ?? 'Unknown';
                      leadingWidget = imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child:
                                  const Icon(Icons.image, color: Colors.grey),
                            );

                      return ListTile(
                        leading: leadingWidget,
                        title: Text(result['title']),
                        subtitle: Text('Tạo bởi: $createdBy'),
                        onTap: () => _navigateToCourseDetail(result['_id']),
                      );
                    }
                  },
                ),
    );
  }
}
