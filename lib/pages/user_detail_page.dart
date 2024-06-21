import 'package:course_app/models/courses.model.dart';
import 'package:course_app/pages/course_detail_page.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:flutter/material.dart';
import 'package:course_app/models/users.model.dart';
import 'package:course_app/services/api_user_services.dart';
import 'package:intl/intl.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;

  const UserDetailPage({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder<User>(
        future: fetchUserInfo(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            final formattedDate =
                DateFormat('dd/MM/yyyy').format(user.joinDate);
            return Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user.imageUrl != null
                            ? NetworkImage(user.imageUrl!)
                            : const ExactAssetImage(
                                    'assets/images/profile_picture.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: Text('Email: ${user.email}'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.date_range),
                        title: Text('Ngày Tham gia: $formattedDate'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.work),
                        title: Text(
                            'Chức nghiệp: ${user.specialty?.specialtyName ?? 'N/A'}'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Course>>(
                    future: ApiCourseServices.fetchCoursesByUserId(userId),
                    builder: (context, courseSnapshot) {
                      if (courseSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (courseSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${courseSnapshot.error}'));
                      } else if (courseSnapshot.hasData) {
                        final courses = courseSnapshot.data!;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Text(
                                'KHOÁ HỌC: ${courses.length}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: courses.length,
                                itemBuilder: (context, index) {
                                  final course = courses[index];
                                  return ListTile(
                                    leading: Image.network(course.imageUrl,
                                        width: 100,
                                        height: 50,
                                        fit: BoxFit.cover),
                                    title: Text(course.title),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CourseDetailPage(
                                                  courseId: course.id,
                                                  userId: userId),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Center(child: Text('No courses found'));
                      }
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No user data'));
          }
        },
      ),
    );
  }
}
