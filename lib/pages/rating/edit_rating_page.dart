import 'package:course_app/models/courses.model.dart';
import 'package:course_app/pages/rating/rating_detail_page.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:course_app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:course_app/models/rating.model.dart';
import 'package:course_app/services/api_rating_service.dart';

class EditRatingPage extends StatefulWidget {
  final Rating rating;
  final String courseId;

  EditRatingPage({required this.rating, required this.courseId});

  @override
  _EditRatingPageState createState() => _EditRatingPageState();
}

class _EditRatingPageState extends State<EditRatingPage> {
  // ignore: prefer_final_fields
  TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;
  late Future<Course> _courseFuture;
  // ignore: unused_field
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _reviewController.text = widget.rating.review ?? '';
    _rating = widget.rating.score.toDouble();
    _courseFuture = ApiCourseServices.fetchCourseById(widget.courseId);
    _reviewController.addListener(() {
      setState(() {
        _charCount = _reviewController.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa đánh giá', style: AppStyles.headerText),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              bool confirmDelete = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận xoá'),
                  content:
                      const Text('Bạn có chắc muốn xoá đánh giá này không?'),
                  actions: [
                    TextButton(
                      child: const Text('Huỷ'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('Xoá'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                try {
                  await ApiRatingServices.deleteRating(widget.rating.id);
                  setState(() {
                    ApiRatingServices.getRatingsByCourseId(widget.courseId);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xoá thành công'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RatingDetailPage(
                            courseId: widget.courseId,
                            userId: widget.rating.userId)),
                  );
                } catch (e) {
                  print('Error deleting rating: $e');
                }
              }
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
      body: FutureBuilder<Course>(
          future: _courseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final course = snapshot.data!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          course.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(course.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16.0),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 55.0,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _reviewController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 600,
                        maxLines: 8,
                        onChanged: (text) {
                          setState(() {
                            _charCount = text.length;
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (_rating > 0) {
                              Rating updatedRating = Rating(
                                id: widget.rating.id,
                                userId: widget.rating.userId,
                                courseId: widget.rating.courseId,
                                score: _rating.toInt(),
                                review: _reviewController.text,
                                ratingDate: widget.rating.ratingDate,
                              );
                              try {
                                Rating result =
                                    await ApiRatingServices.updateRating(
                                  updatedRating.id,
                                  updatedRating,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Đánh giá đã được cập nhật thành công'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context, result);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RatingDetailPage(
                                          courseId: widget.courseId,
                                          userId: widget.rating.userId)),
                                );
                              } catch (e) {
                                print('Error updating rating: $e');
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng chọn số sao'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text(
                            'Lưu chỉnh sửa',
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text('No course data available'));
            }
          }),
    );
  }
}
