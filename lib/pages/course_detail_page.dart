import 'package:course_app/models/fav.model.dart';
import 'package:course_app/pages/user_detail_page.dart';
import 'package:course_app/services/api_fav_services.dart';
import 'package:flutter/material.dart';
import 'package:course_app/models/courses.model.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:course_app/pages/play_episode_page.dart';
import 'package:intl/intl.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  final String userId;

  const CourseDetailPage(
      {required this.courseId, Key? key, required this.userId})
      : super(key: key);

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with SingleTickerProviderStateMixin {
  late Future<Course> _courseFuture;
  late TabController _tabController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _courseFuture = ApiCourseServices.fetchCourseById(widget.courseId);
    _tabController = TabController(length: 2, vsync: this);
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    try {
      List<Favorite> favorites =
          await FavoriteService.getFavoritesByCourseId(widget.courseId);
      setState(() {
        _isFavorite = favorites.isNotEmpty;
      });
    } catch (e) {
      print('Failed to check favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        List<Favorite> favorites =
            await FavoriteService.getFavoritesByCourseId(widget.courseId);
        if (favorites.isNotEmpty) {
          await FavoriteService.deleteFavorite(favorites[0].id);
        }
      } else {
        await FavoriteService.addFavorite(widget.userId, widget.courseId);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      print('Failed to toggle favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết khoá học',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<Course>(
        future: _courseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final course = snapshot.data!;
            final formattedDate =
                DateFormat('dd/MM/yyyy').format(course.creationDate);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(course.imageUrl),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Nội dung khoá học'),
                      Tab(text: 'Phần học'),
                    ],
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Course Content Tab
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    //the userId field in your Course model might be a String instead of a Map.
                                    //This discrepancy can cause issues when the code tries to access course.userId['_id']
                                    String userId;
                                    if (course.userId is Map<String, dynamic>) {
                                      userId = course.userId['_id'];
                                    } else {
                                      userId = course.userId;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserDetailPage(
                                          userId: userId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.person),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Text(
                                          '${course.userId['full_name']}',
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.date_range),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  course.description,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Episode List Tab
                        ListView.builder(
                          itemCount: course.episodes.length,
                          itemBuilder: (context, index) {
                            final episode = course.episodes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: ListTile(
                                leading: Image.network(
                                  episode.imageUrl,
                                  width: 100,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(episode.title),
                                subtitle: Text(
                                    'Thời lượng: ${episode.duration ~/ 60} phút'),
                                trailing: const Icon(Icons.play_arrow),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlayEpisodePage(
                                        episodeId: episode.id,
                                        episodes: course.episodes,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
