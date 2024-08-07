import 'package:course_app/models/fav.model.dart';
import 'package:course_app/pages/course/course_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:course_app/services/api_fav_services.dart';

class FavPage extends StatefulWidget {
  final String userId;

  const FavPage({required this.userId, Key? key}) : super(key: key);

  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  late Future<List<Favorite>> futureFavorites;
  List<Favorite> _favorites = [];

  @override
  void initState() {
    super.initState();
    futureFavorites = fetchUserFavorites(widget.userId);
  }

  Future<List<Favorite>> fetchUserFavorites(String userId) async {
    return await FavoriteService.getFavoritesByUserId(userId);
  }

  void removeFavorite(String favId) {
    FavoriteService.deleteFavorite(favId).then((_) {
      setState(() {
        futureFavorites = fetchUserFavorites(widget.userId);
        _favorites.removeWhere((favorite) => favorite.id == favId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã xóa thành công',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }).catchError((error) {
      print('Failed to remove favorite: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.remove_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to remove favorite: $error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    });
  }

  Future<void> deleteAllFavoritesSequentially() async {
    try {
      await Future.forEach(_favorites.toList(), (favorite) async {
        await FavoriteService.deleteFavorite(favorite.id);
      });
      setState(() {
        futureFavorites = fetchUserFavorites(widget.userId);
        _favorites.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã xóa tất cả thành công',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    } catch (error) {
      print('Failed to delete all favorites: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.remove_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to delete all favorites: $error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
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

  Future<void> _showErrorDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lỗi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
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

  Future<bool> confirmDelete(String favId) async {
    bool confirm = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Bạn có chắc chắn muốn xóa mục này không?',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Huỷ'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(20),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        );
      },
    );

    return confirm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // color: Colors.white,
            border: Border.all(color: const Color(0xFFeeeeee)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "KHÓA HỌC YÊU THÍCH",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004FCA),
              ),
            ),
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(bottom: 3.0, right: 5),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.circular(
        //             5), // Adjust the radius for square shape
        //       ),
        //       child: PopupMenuButton<String>(
        //         offset: const Offset(0, 50),
        //         icon: const Icon(Icons.more_vert),
        //         onSelected: (value) {
        //           if (value == 'deleteAll') {
        //             deleteAllFavoritesSequentially();
        //           }
        //         },
        //         itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        //           const PopupMenuItem<String>(
        //             value: 'deleteAll',
        //             child: ListTile(
        //               leading: Icon(Icons.delete),
        //               title: Text('Xóa tất cả'),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ],
        // backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        // color: Colors.white,
        child: FutureBuilder<List<Favorite>>(
          future: futureFavorites,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Chưa có khóa học nào !'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No favorites found'));
            } else {
              _favorites = snapshot.data!;
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final favorite = snapshot.data![index];
                  final course = favorite.course;
                  return Dismissible(
                    key: Key(favorite.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        return await confirmDelete(favorite.id);
                      } else {
                        return true;
                      }
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      removeFavorite(favorite.id);
                    },
                    child: InkWell(
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
                        // color: const Color(0xFFF8F8F8),
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
                                    // const SizedBox(height: 4.0),
                                    // Text(
                                    //   course.userId,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   maxLines: 2,
                                    //   style: const TextStyle(
                                    //     fontSize: 13,
                                    //     fontWeight: FontWeight.w400,
                                    //     color: Color(0xFF979797),
                                    //   ),
                                    // ),
                                  ],
                                ),
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
    );
  }
}
