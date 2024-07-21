import 'package:course_app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:course_app/models/courses.model.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:course_app/pages/course/course_detail_page.dart';
import 'package:course_app/pages/search_page.dart';

class CourseListByCate extends StatefulWidget {
  final String userId;
  final String categoryId;
  final String categoryName;

  const CourseListByCate({
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    Key? key,
  }) : super(key: key);

  @override
  State<CourseListByCate> createState() => _CourseListByCateState();
}

class _CourseListByCateState extends State<CourseListByCate> {
  late Future<List<Course>> futureCourses;

  @override
  void initState() {
    super.initState();
    futureCourses = ApiCourseServices.getCoursesByCategory(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.categoryName,
            style: AppStyles.headerText,
          ),
        ),
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
                  builder: (context) => SearchPage(
                    userId: widget.userId,
                  ),
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
      body: FutureBuilder<List<Course>>(
        future: futureCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Chưa có khóa học nào cho danh mục này'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final course = snapshot.data![index];
                return InkWell(
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
                  child: Card(
                    margin: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      top: 15,
                    ),
                    color: const Color(0xFFF8F8F8),
                    elevation: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20, bottom: 20, left: 15, right: 15),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: Image.network(
                              course.imageUrl,
                              width: 70,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 5,
                              top: 20,
                              right: 15,
                              bottom: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  course.userId['full_name'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF979797),
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}
