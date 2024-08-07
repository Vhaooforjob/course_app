import 'package:course_app/models/courses.model.dart';
import 'package:course_app/pages/search_page.dart';
import 'package:course_app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:course_app/pages/course/course_detail_page.dart';

class CourseList extends StatefulWidget {
  final String userId;

  CourseList({Key? key, required this.userId}) : super(key: key);

  @override
  State<CourseList> createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  late Future<List<Course>> futureLatestCourses;
  late Future<List<Course>> futureCourses;
  bool isSearching = false;
  // ignore: unused_field
  final TextEditingController _searchController = TextEditingController();
  List<Course> _allCourses = [];
  List<Course> _displayedCourses = [];

  @override
  void initState() {
    super.initState();
    futureLatestCourses = ApiCourseServices.fetchLatestCourses(limit: 5);
    futureCourses = ApiCourseServices.fetchCourses().then((courses) {
      setState(() {
        _allCourses = courses;
        _displayedCourses = courses;
      });
      return courses;
    });
  }

  void _sortCourses(String sortOption) {
    setState(() {
      if (sortOption == 'newest') {
        _displayedCourses
            .sort((a, b) => b.creationDate.compareTo(a.creationDate));
      } else if (sortOption == 'oldest') {
        _displayedCourses
            .sort((a, b) => a.creationDate.compareTo(b.creationDate));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Danh Sách Khóa học", style: AppStyles.headerText),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/search_icon_black.png',
              width: 16,
              height: 16,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 15,
            ),
            child: Text(
              'Khóa học mới',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 205,
            child: FutureBuilder<List<Course>>(
              future: futureLatestCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có khóa học nào.'));
                } else {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final course = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailPage(
                                courseId: course.id,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 24 : 12,
                            right: index == snapshot.data!.length - 1 ? 24 : 0,
                          ),
                          child: Container(
                            width: 170,
                            height: 205,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    course.imageUrl,
                                    width: 168,
                                    height: 130,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        course.title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        course.userId['full_name'],
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32, left: 25, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tất cả khóa học",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Image.network(
                    'https://i.ibb.co/tHMJcpV/Screenshot-2024-06-05-at-16-33-1.png',
                    width: 24,
                    height: 24,
                  ),
                  onSelected: (value) {
                    _sortCourses(value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'newest',
                      child: Text('Gần đây nhất'),
                    ),
                    const PopupMenuItem(
                      value: 'oldest',
                      child: Text('Trễ nhất'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: FutureBuilder<List<Course>>(
                future: futureCourses,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có khóa học nào.'));
                  } else {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: _displayedCourses.length,
                      itemBuilder: (context, index) {
                        final course = _displayedCourses[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailPage(
                                  courseId: course.id,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    course.imageUrl,
                                    width: double.infinity,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        course.title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        course.userId['full_name'],
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
