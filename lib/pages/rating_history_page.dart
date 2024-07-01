import 'package:course_app/models/courses.model.dart';
import 'package:course_app/models/rating.model.dart';
import 'package:course_app/pages/edit_rating_page.dart';
import 'package:course_app/services/api_rating_service.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:course_app/models/users.model.dart';
import 'package:course_app/services/api_user_services.dart';
import 'package:course_app/services/api_course_services.dart'; // Thêm import này

class RatingHistoryPage extends StatefulWidget {
  final String userId;

  const RatingHistoryPage({required this.userId, Key? key}) : super(key: key);

  @override
  _RatingHistoryPageState createState() => _RatingHistoryPageState();
}

class _RatingHistoryPageState extends State<RatingHistoryPage> {
  late Future<List<Rating>> _userRatingsFuture;

  @override
  void initState() {
    super.initState();
    _userRatingsFuture = ApiRatingServices.getRatingsByUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đánh giá của bạn'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Rating>>(
          future: _userRatingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Lỗi khi tải đánh giá'));
            } else if (snapshot.hasData) {
              final ratings = snapshot.data!;
              if (ratings.isEmpty) {
                return const Center(child: Text('Bạn chưa có đánh giá nào'));
              } else {
                return ListView.builder(
                  itemCount: ratings.length,
                  itemBuilder: (context, index) {
                    final rating = ratings[index];
                    return _buildRatingItem(rating);
                  },
                );
              }
            } else {
              return const Center(child: Text('Không có đánh giá nào'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildRatingItem(Rating rating) {
    return FutureBuilder<User>(
      future: fetchUserInfo(rating.userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('Đang tải...'),
          );
        } else if (userSnapshot.hasError) {
          return ListTile(
            leading: const Icon(Icons.error),
            title: Text('Error: ${userSnapshot.error}'),
          );
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data!;
          return FutureBuilder<Course>(
            future: ApiCourseServices.fetchCourseById(rating.courseId),
            builder: (context, courseSnapshot) {
              if (courseSnapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Đang tải...'),
                );
              } else if (courseSnapshot.hasError) {
                return ListTile(
                  leading: const Icon(Icons.error),
                  title: Text('Error: ${courseSnapshot.error}'),
                );
              } else if (courseSnapshot.hasData) {
                final course = courseSnapshot.data!;
                return Container(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.imageUrl != null
                                ? NetworkImage(user.imageUrl!)
                                : const AssetImage(
                                    'assets/images/profile_picture.png'),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(course.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(user.fullName),
                              RatingBarIndicator(
                                rating: rating.score.toDouble(),
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20.0,
                                direction: Axis.horizontal,
                              ),
                            ],
                          ),
                          trailing: rating.userId == widget.userId
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Image.asset(
                                          'assets/images/edit_profile.png',
                                          width: 16.0,
                                          height: 16.0),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditRatingPage(
                                              rating: rating,
                                              courseId: rating.courseId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // IconButton(
                                    //   icon: const Icon(Icons.delete_outline_rounded),
                                    //   onPressed: () async {
                                    //     bool confirmDelete = await showDialog(
                                    //       context: context,
                                    //       builder: (context) => AlertDialog(
                                    //         title: const Text('Xác nhận xoá'),
                                    //         content: const Text(
                                    //             'Bạn có chắc muốn xoá đánh giá này không?'),
                                    //         actions: [
                                    //           TextButton(
                                    //             child: const Text('Huỷ'),
                                    //             onPressed: () {
                                    //               Navigator.of(context).pop(false);
                                    //             },
                                    //           ),
                                    //           TextButton(
                                    //             child: const Text('Xoá'),
                                    //             onPressed: () {
                                    //               Navigator.of(context).pop(true);
                                    //             },
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     );

                                    //     if (confirmDelete == true) {
                                    //       try {
                                    //         await ApiRatingServices.deleteRating(
                                    //             rating.id);
                                    //         setState(() {
                                    //           _ratingsFuture = ApiRatingServices
                                    //               .getRatingsByCourseId(
                                    //                   widget.courseId);
                                    //           _ratingChanged = true;
                                    //         });
                                    //       } catch (e) {
                                    //         print('Error deleting rating: $e');
                                    //       }
                                    //     }
                                    //   },
                                    // ),
                                  ],
                                )
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(74, 0, 30, 16),
                          child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                              children: [
                                WidgetSpan(
                                  child: ExpandableText(
                                    rating.review ??
                                        'Người dùng không viết nhận xét',
                                    expandText: 'Xem thêm',
                                    collapseText: 'Thu gọn',
                                    maxLines: 3,
                                    linkColor: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                );
              } else {
                return const ListTile(
                  title: Text('Không có thông tin khoá học'),
                );
              }
            },
          );
        } else {
          return const ListTile(
            title: Text('Không có thông tin người dùng'),
          );
        }
      },
    );
  }
}
