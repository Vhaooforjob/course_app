import 'package:flutter/material.dart';
import 'package:course_app/models/categories.model.dart';
import 'package:course_app/pages/course_detail_page.dart';
import 'package:course_app/pages/user_detail_page.dart';
import 'package:course_app/services/api_categories_services.dart';
import 'package:course_app/services/api_search_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  final String userId;

  SearchPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  bool _noResults = false;
  bool _isSearching = false;
  late Future<List<Categories>> futureCategories;
  String _currentSearchType = 'users + courses';
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    futureCategories = ApiCategoryServices.fetchCategories();
    _loadSearchHistory();
  }

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
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _noResults = false;
      _isSearching = true;
    });

    try {
      Map<String, dynamic> data = {};
      List<dynamic> dataOnlySearch = [];
      if (_currentSearchType == 'users') {
        dataOnlySearch = await APISearchServices.searchUsersQuery(query);
      } else if (_currentSearchType == 'courses') {
        dataOnlySearch = await APISearchServices.searchCoursesQuery(query);
      } else {
        data = await APISearchServices.searchQuery(query);
      }
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searchResults.addAll(dataOnlySearch);
          if (data.containsKey('users')) {
            _searchResults.addAll(data['users']);
          }
          if (data.containsKey('courses')) {
            _searchResults.addAll(data['courses']);
          }
          _isLoading = false;
          _noResults = _searchResults.isEmpty;
        });
      }
      if (!_searchHistory.contains(query)) {
        _saveSearchHistory(query);
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

  void _navigateToUserDetail(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailPage(userId: userId)),
    );
  }

  void _navigateToCourseDetail(String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CourseDetailPage(
                courseId: courseId,
                userId: widget.userId,
              )),
    );
  }

  Future<void> _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _searchHistory.add(query);
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  Future<void> _deleteSearchHistoryItem(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
    });
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  Future<void> _clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {
      _searchHistory = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/search_page_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: Image(
                                    image: AssetImage(
                                        'assets/images/search_icon_grey.png'),
                                    width: 16,
                                    height: 16,
                                  )),
                              const SizedBox(width: 5),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Tìm kiếm...',
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 10),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    _search(value);
                                  },
                                ),
                              ),
                              if (_isSearching)
                                IconButton(
                                  icon: Image.asset(
                                    'assets/images/x_icon_gray.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isSearching = false;
                                      _searchController.clear();
                                      _searchResults = [];
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  iconSize: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    if (_isSearching)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentSearchType = 'users + courses';
                                _search(_searchController.text);
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Tất cả',
                                style: TextStyle(
                                  color: _currentSearchType == 'users + courses'
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                  fontWeight:
                                      _currentSearchType == 'users + courses'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentSearchType = 'users';
                                _search(_searchController.text);
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Người dùng',
                                style: TextStyle(
                                  color: _currentSearchType == 'users'
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                  fontWeight: _currentSearchType == 'users'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentSearchType = 'courses';
                                _search(_searchController.text);
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Khóa học',
                                style: TextStyle(
                                  color: _currentSearchType == 'courses'
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                  fontWeight: _currentSearchType == 'courses'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 0,
                          bottom: 16,
                          left: 16,
                          right: 16,
                        ),
                      ),
                    if (!_isSearching & _searchHistory.isNotEmpty)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: const Text(
                              'LỊCH SỬ TÌM KIẾM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!_isSearching && _searchHistory.isNotEmpty)
                      Expanded(
                        child: _searchHistory.isNotEmpty
                            ? ListView.builder(
                                itemCount: _searchHistory.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == _searchHistory.length) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: ListTile(
                                        title: const Text(
                                          'Xoá tất cả',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                        onTap: _clearSearchHistory,
                                      ),
                                    );
                                  }
                                  return ListTile(
                                    title: Text(_searchHistory[index],
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    leading: const Icon(Icons.history,
                                        color: Colors.white, size: 20.0),
                                    trailing: IconButton(
                                      icon: const Image(
                                        image: AssetImage(
                                            'assets/images/x_icon_white.png'),
                                        width: 20,
                                        height: 20,
                                      ),
                                      onPressed: () {
                                        _deleteSearchHistoryItem(
                                            _searchHistory[index]);
                                      },
                                    ),
                                    onTap: () {
                                      _searchController.text =
                                          _searchHistory[index];
                                      _search(_searchHistory[index]);
                                    },
                                  );
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    if (!_isSearching)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: const Text(
                              'TÌM KIẾM THEO CHỦ ĐỀ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!_isSearching)
                      FutureBuilder<List<Categories>>(
                        future: futureCategories,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(
                                spacing: 20.0,
                                runSpacing: 16.0,
                                children:
                                    snapshot.data!.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Categories category = entry.value;
                                  if (index < 16) {
                                    return SizedBox(
                                      width: 72,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  spreadRadius: 1,
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Image.network(
                                                category.img ?? '',
                                                width: 40,
                                                height: 40,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            category.categoryName,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            maxLines: 8,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }).toList(),
                              ),
                            );
                          } else {
                            return const Center(
                                child: Text('No data available'));
                          }
                        },
                      ),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _noResults && _isSearching
                              ? const Center(
                                  child: Text(
                                      'Không tìm thấy kết quả tương ứng',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                )
                              : ListView.builder(
                                  itemCount: _searchResults.length +
                                      (_isSearching
                                          ? 0
                                          : _searchHistory.length),
                                  itemBuilder: (context, index) {
                                    if (!_isSearching &&
                                        index < _searchHistory.length) {
                                      return null;
                                    } else {
                                      final resultIndex = index -
                                          (_isSearching
                                              ? 0
                                              : _searchHistory.length);
                                      final result =
                                          _searchResults[resultIndex];
                                      final imageUrl =
                                          result['image_url'] ?? '';
                                      Widget leadingWidget;
                                      if (result.containsKey('full_name')) {
                                        leadingWidget = ClipOval(
                                          child: imageUrl.isNotEmpty
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
                                                  child: const Icon(
                                                      Icons.account_circle,
                                                      color: Colors.grey),
                                                ),
                                        );
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ListTile(
                                            leading: leadingWidget,
                                            title: Text(
                                              result['full_name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                                result['username'] ?? '',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                            onTap: () => _navigateToUserDetail(
                                                result['_id']),
                                          ),
                                        );
                                      } else {
                                        final createdBy = result['user_id']
                                                ['full_name'] ??
                                            'Unknown';
                                        leadingWidget = ClipOval(
                                          child: imageUrl.isNotEmpty
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
                                                  child: const Icon(Icons.image,
                                                      color: Colors.grey),
                                                ),
                                        );
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ListTile(
                                            leading: leadingWidget,
                                            title: Text(
                                              result['title'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Text(
                                                'Tạo bởi: $createdBy',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                            onTap: () =>
                                                _navigateToCourseDetail(
                                                    result['_id']),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
