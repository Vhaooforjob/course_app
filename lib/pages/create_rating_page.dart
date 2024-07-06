import 'package:course_app/models/courses.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:course_app/models/rating.model.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:course_app/services/api_rating_service.dart';
import 'package:intl/intl.dart';

class CreateRatingPage extends StatefulWidget {
  final String userId;
  final String courseId;

  const CreateRatingPage(
      {required this.userId, required this.courseId, super.key});

  @override
  _CreateRatingPageState createState() => _CreateRatingPageState();
}

class _CreateRatingPageState extends State<CreateRatingPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0;
  late Future<Course> _courseFuture;
  // ignore: unused_field
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
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
        title: const Text('Đánh giá'),
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
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                        hintText: 'Nhập vào đây nhận xét của bạn...',
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
                        onPressed: () {
                          if (_rating > 0) {
                            _submitRating(Rating(
                              courseId: widget.courseId,
                              score: _rating.toInt(),
                              review: _reviewController.text.isNotEmpty
                                  ? _reviewController.text
                                  : null,
                              id: '',
                              userId: widget.userId,
                              ratingDate: null,
                            ));
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
                          'Gửi đánh giá',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
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
        },
      ),
    );
  }

  Future<void> _submitRating(Rating rating) async {
    try {
      final createdRating = await ApiRatingServices.createRating(rating);
      // ignore: unnecessary_null_comparison
      if (createdRating != null) {
        _showSuccessModal();
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá không thành công'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi khi gửi đánh giá: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSuccessModal() {
    final now = DateTime.now();
    final formattedDate = DateFormat('HH:mm dd/MM/yyyy').format(now);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isDismissible: false,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 2 / 3,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 16.0),
              const Icon(Icons.thumb_up, color: Colors.blue, size: 100.0),
              const SizedBox(height: 16.0),
              const Text(
                'Cảm ơn bạn',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              const Text(
                'đã chia sẻ đánh giá đến khoá học',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28.0),
              const Text(
                'Đánh giá của bạn đã được gửi',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              Text(
                'thành công vào lúc $formattedDate.',
                style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Trở về',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}
