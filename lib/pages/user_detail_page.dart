import 'package:flutter/material.dart';
import 'package:course_app/models/courses.model.dart';
import 'package:course_app/pages/course_detail_page.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:course_app/models/users.model.dart';
import 'package:course_app/services/api_user_services.dart';
import 'package:intl/intl.dart';
import 'package:course_app/configs/colors.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;
  final String? userCourseId;

  const UserDetailPage({required this.userId, Key? key, this.userCourseId})
      : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool showDetails = false;
  double turns = 0;
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    if (widget.userCourseId != null) {
      try {
        final fetchedUser = await fetchUserInfo(widget.userCourseId!);
        setState(() {
          user = fetchedUser;
          isLoading = false;
        });
      } catch (error) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      try {
        final fetchedUser = await fetchUserInfo(widget.userId);
        setState(() {
          user = fetchedUser;
          isLoading = false;
        });
      } catch (error) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Hình nền
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/profile_page.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 20),
              // Phần thông tin người dùng
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (user == null)
                const Center(child: Text('Không tìm thấy dữ liệu'))
              else
                Column(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: user!.imageUrl != null
                          ? NetworkImage(user!.imageUrl!)
                          : const AssetImage(
                                  'assets/images/profile_picture.png')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user!.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            setState(() {
                              showDetails = !showDetails;
                              turns = showDetails ? 0.5 : 0;
                            });
                          },
                          child: AnimatedRotation(
                            turns: turns,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue,
                              ),
                              child: const Icon(Icons.arrow_downward,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      height: showDetails ? null : 0,
                      child: Visibility(
                        visible: showDetails,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListTile(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(50, 20, 0, 0),
                              leading: const Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                              title: Text(
                                'Email: ${user!.email}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            ListTile(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(50, 0, 0, 0),
                              leading: const Icon(Icons.date_range,
                                  color: Colors.white),
                              title: Text(
                                'Ngày tham gia: ${DateFormat('dd/MM/yyyy').format(user!.joinDate)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            ListTile(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(50, 0, 0, 0),
                              leading:
                                  const Icon(Icons.work, color: Colors.white),
                              title: Text(
                                'Chức nghiệp: ${user!.specialty?.specialtyName ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              // Container màu trắng với góc bo tròn cho các khóa học
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  height: showDetails
                      ? MediaQuery.of(context).size.height * 0.4
                      : MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: CourseList(
                      userId: widget.userId,
                      userCourseId: widget.userCourseId!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CourseList extends StatefulWidget {
  final String userId;
  final String? userCourseId;

  const CourseList({required this.userId, this.userCourseId, Key? key})
      : super(key: key);

  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = fetchCoursesFuture();
  }

  Future<List<Course>> fetchCoursesFuture() async {
    if (widget.userCourseId != null) {
      try {
        return await ApiCourseServices.fetchCoursesByUserId(
            widget.userCourseId!);
      } catch (error) {
        rethrow;
      }
    } else {
      try {
        return await ApiCourseServices.fetchCoursesByUserId(widget.userId);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: _coursesFuture,
      builder: (context, courseSnapshot) {
        if (courseSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (courseSnapshot.hasError) {
          return Center(child: Text('Lỗi: ${courseSnapshot.error}'));
        } else if (courseSnapshot.hasData) {
          final courses = courseSnapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('KHÓA HỌC: ${courses.length}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: blue004FCA)),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: blue004FCA),
                      onPressed: () {
                        // Handle filter action here
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              course.imageUrl,
                              width: 100,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(course.title),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailPage(
                                    courseId: course.id, userId: widget.userId),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: greyD9D9D9,
                          height: 20,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('Không tìm thấy khóa học'));
        }
      },
    );
  }
}
