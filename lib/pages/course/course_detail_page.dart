import 'package:course_app/models/fav.model.dart';
import 'package:course_app/models/rating.model.dart';
import 'package:course_app/pages/rating/rating_detail_page.dart';
import 'package:course_app/pages/user/user_detail_page.dart';
import 'package:course_app/services/api_fav_services.dart';
import 'package:course_app/services/api_rating_service.dart';
import 'package:course_app/styles/styles.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:course_app/models/courses.model.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:course_app/pages/course/play_episode_page.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  late Future<List<Rating>> _ratingsFuture;
  late TabController _tabController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _courseFuture = ApiCourseServices.fetchCourseById(widget.courseId);
    _ratingsFuture = ApiRatingServices.getRatingsByCourseId(widget.courseId);
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
      _showFavoriteDialog(
          _isFavorite ? 'Đã thêm vào danh sách yêu thích' : 'Đã hủy yêu thích');
    } catch (e) {
      print('Failed to toggle favorite: $e');
    }
  }

  void _showFavoriteDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshCourseData() async {
    setState(() {
      _courseFuture = ApiCourseServices.fetchCourseById(widget.courseId);
      _ratingsFuture = ApiRatingServices.getRatingsByCourseId(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết khoá học', style: AppStyles.headerText),
        centerTitle: true,
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
            int totalDuration = course.episodes
                .fold(0, (sum, episode) => sum + episode.duration);
            int totalVideos = course.episodes.length;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        course.imageUrl,
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
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
                        Row(
                          children: [
                            const Icon(Icons.video_library, size: 16.0),
                            const SizedBox(width: 8.0),
                            Text(
                              '$totalVideos video |',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(Icons.timer, size: 16.0),
                            const SizedBox(width: 8.0),
                            Text(
                              '${totalDuration ~/ 60} phút',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            // const Text(
                            //   'Yêu thích',
                            //   style: TextStyle(
                            //     fontSize: 16.0,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            Stack(
                              children: [
                                const Positioned(
                                  top: 8.0,
                                  left: 50.0,
                                  child: Text(
                                    'Yêu thích',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _isFavorite
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 20.0,
                                    ),
                                    onPressed: _toggleFavorite,
                                  ),
                                ),
                              ],
                            )
                          ],
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
                                    String userIdCheck;
                                    if (course.userId is Map<String, dynamic>) {
                                      userIdCheck = course.userId['_id'];
                                    } else {
                                      userIdCheck = course.userId;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserDetailPage(
                                          userId: widget.userId,
                                          userCourseId: userIdCheck,
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
                                RichText(
                                  textAlign: TextAlign.justify,
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 16.0, color: Colors.black),
                                    children: [
                                      WidgetSpan(
                                        child: ExpandableText(
                                            course.description,
                                            expandText: 'Xem thêm',
                                            collapseText: 'Thu gọn',
                                            maxLines: 3,
                                            linkColor: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Row(
                                  children: [
                                    const Text(
                                      'Đánh giá của khoá học',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RatingDetailPage(
                                              courseId: widget.courseId,
                                              userId: widget.userId,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _refreshCourseData();
                                        }
                                      },
                                      child: const Text(
                                        'Xem chi tiết',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          // color: Colors.blue,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // const Text(
                                //   'Đánh giá của khoá học',
                                //   style: TextStyle(
                                //     fontSize: 18.0,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                FutureBuilder<List<Rating>>(
                                  future: _ratingsFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                          child:
                                              // Text('Error: ${snapshot.error}'));
                                              Text(''));
                                    } else if (snapshot.hasData) {
                                      final ratings = snapshot.data!;
                                      double averageRating = 0.0;
                                      if (ratings.isNotEmpty) {
                                        double totalScore = ratings
                                            .map((rating) =>
                                                rating.score.toDouble())
                                            .reduce((a, b) => a + b);
                                        averageRating =
                                            totalScore / ratings.length;
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            averageRating
                                                                .toStringAsFixed(
                                                                    1),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 40.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        RatingBarIndicator(
                                                          rating: averageRating,
                                                          itemBuilder: (context,
                                                                  index) =>
                                                              const Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber),
                                                          itemCount: 5,
                                                          itemSize: 20.0,
                                                          direction:
                                                              Axis.horizontal,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      5.0,
                                                                  vertical:
                                                                      8.0),
                                                          child: Text(
                                                              '${ratings.length} đánh giá'),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Column(
                                          //   children: ratings.map((rating) {
                                          //     return FutureBuilder<User>(
                                          //       future: fetchUserInfo(
                                          //           rating.userId),
                                          //       builder:
                                          //           (context, userSnapshot) {
                                          //         if (userSnapshot
                                          //                 .connectionState ==
                                          //             ConnectionState.waiting) {
                                          //           return const ListTile(
                                          //             leading:
                                          //                 CircularProgressIndicator(),
                                          //             title:
                                          //                 Text('đang tải...'),
                                          //           );
                                          //         } else if (userSnapshot
                                          //             .hasError) {
                                          //           return ListTile(
                                          //             leading: const Icon(
                                          //                 Icons.error),
                                          //             title: Text(
                                          //                 'Error: ${userSnapshot.error}'),
                                          //           );
                                          //         } else if (userSnapshot
                                          //             .hasData) {
                                          //           final user =
                                          //               userSnapshot.data!;
                                          //           return ListTile(
                                          //             leading: CircleAvatar(
                                          //               backgroundImage: user
                                          //                           .imageUrl !=
                                          //                       null
                                          //                   ? NetworkImage(
                                          //                       user.imageUrl!)
                                          //                   : const AssetImage(
                                          //                       'assets/images/profile_picture.png'),
                                          //             ),
                                          //             title:
                                          //                 Text(user.fullName),
                                          //             subtitle: Column(
                                          //               crossAxisAlignment:
                                          //                   CrossAxisAlignment
                                          //                       .start,
                                          //               children: [
                                          //                 RatingBarIndicator(
                                          //                   rating: rating.score
                                          //                       .toDouble(),
                                          //                   itemBuilder:
                                          //                       (context,
                                          //                               index) =>
                                          //                           const Icon(
                                          //                     Icons.star,
                                          //                     color:
                                          //                         Colors.amber,
                                          //                   ),
                                          //                   itemCount: 5,
                                          //                   itemSize: 16.0,
                                          //                   direction:
                                          //                       Axis.horizontal,
                                          //                 ),
                                          //                 const SizedBox(
                                          //                     height: 4.0),
                                          //                 Text(rating.review ??
                                          //                     'Người dùng không viết nhận xét'),
                                          //               ],
                                          //             ),
                                          //           );
                                          //         } else {
                                          //           return const ListTile(
                                          //             title: Text(
                                          //                 'No user information available'),
                                          //           );
                                          //         }
                                          //       },
                                          //     );
                                          //   }).toList(),
                                          // ),
                                        ],
                                      );
                                    } else {
                                      return const Center(
                                          child: Text('No ratings available'));
                                    }
                                  },
                                )
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
                                  horizontal: 16.0, vertical: 4.0),
                              color: Colors.white,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    episode.imageUrl,
                                    width: 100,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  episode.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
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
