import 'package:course_app/models/users.model.dart';
import 'package:course_app/pages/rating/create_rating_page.dart';
import 'package:course_app/pages/rating/edit_rating_page.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:course_app/services/api_user_services.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:course_app/models/rating.model.dart';
import 'package:course_app/services/api_rating_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class RatingDetailPage extends StatefulWidget {
  final String courseId;
  final String userId;

  const RatingDetailPage(
      {required this.courseId, required this.userId, Key? key})
      : super(key: key);

  @override
  _RatingDetailPageState createState() => _RatingDetailPageState();
}

class _RatingDetailPageState extends State<RatingDetailPage> {
  late Future<List<Rating>> _ratingsFuture;
  bool _isCourseOwner = false;
  bool _userRated = false;
  bool _ratingChanged = false;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ratingsFuture = ApiRatingServices.getRatingsByCourseId(widget.courseId);
    _checkCourseOwner();
    _checkUserRated();
  }

  Future<void> _checkCourseOwner() async {
    try {
      final courses =
          await ApiCourseServices.fetchCoursesByUserId(widget.userId);
      for (var course in courses) {
        if (course.id == widget.courseId) {
          setState(() {
            _isCourseOwner = true;
          });
          break;
        }
      }
    } catch (e) {
      print('Error checking course owner: $e');
    }
  }

  Future<void> _checkUserRated() async {
    try {
      final ratings =
          await ApiRatingServices.getRatingsByCourseId(widget.courseId);
      setState(() {
        _userRated = ratings.any((rating) => rating.userId == widget.userId);
      });
    } catch (e) {
      print('Error checking if user has rated: $e');
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá khoá học'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context, _ratingChanged);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FutureBuilder<List<Rating>>(
                future: _ratingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Chưa có đánh giá nào'));
                  } else if (snapshot.hasData) {
                    final ratings = snapshot.data!;
                    List<Rating> pinnedReviews = [];
                    List<Rating> otherReviews = [];
                    for (var rating in ratings) {
                      if (rating.userId == widget.userId) {
                        pinnedReviews.add(rating);
                      } else {
                        otherReviews.add(rating);
                      }
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: pinnedReviews.length + otherReviews.length,
                      itemBuilder: (context, index) {
                        if (index < pinnedReviews.length) {
                          final rating = pinnedReviews[index];
                          return _buildRatingItem(rating, isPinned: true);
                        } else {
                          final rating =
                              otherReviews[index - pinnedReviews.length];
                          return _buildRatingItem(rating, isPinned: false);
                        }
                      },
                    );
                  } else {
                    return const Center(child: Text('No ratings available'));
                  }
                },
              ),
            ),
            if (!_isCourseOwner && !_userRated)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateRatingPage(
                            userId: widget.userId,
                            courseId: widget.courseId,
                          ),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          _ratingsFuture =
                              ApiRatingServices.getRatingsByCourseId(
                            widget.courseId,
                          );
                          _ratingChanged = true;
                        });
                        _scrollToTop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send_rounded),
                        SizedBox(width: 8.0),
                        Text('Viết đánh giá'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem(Rating rating, {required bool isPinned}) {
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
          return Container(
            decoration: BoxDecoration(
              color: isPinned ? Colors.indigo[50] : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.imageUrl != null
                        ? NetworkImage(user.imageUrl!)
                        : const AssetImage('assets/images/profile_picture.png'),
                  ),
                  title: Text(user.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        rating.ratingDate != null
                            ? DateFormat('HH:mm dd/MM/yyyy')
                                .format(rating.ratingDate!)
                            : 'N/A',
                        style:
                            const TextStyle(fontSize: 12.0, color: Colors.grey),
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
                                final editedRating = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditRatingPage(
                                      rating: rating,
                                      courseId: widget.courseId,
                                    ),
                                  ),
                                );
                                if (editedRating != null) {
                                  setState(() {
                                    _ratingsFuture =
                                        ApiRatingServices.getRatingsByCourseId(
                                            widget.courseId);
                                    _ratingChanged = true;
                                  });
                                  _scrollToTop();
                                }
                              },
                            ),
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
                            rating.review ?? 'Người dùng không viết nhận xét',
                            expandText: 'Xem thêm',
                            collapseText: 'Thu gọn',
                            maxLines: 3,
                            linkColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return const ListTile(
            title: Text('No user information available'),
          );
        }
      },
    );
  }
}
