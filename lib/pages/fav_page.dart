import 'package:course_app/models/fav.model.dart';
import 'package:course_app/pages/course_detail_page.dart';
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
      _showSuccessDialog('Đã xóa thành công');
    }).catchError((error) {
      print('Failed to remove favorite: $error');
      _showErrorDialog('Failed to remove favorite: $error');
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
      _showSuccessDialog('Đã xóa tất cả thành công');
    } catch (error) {
      print('Failed to delete all favorites: $error');
      _showErrorDialog('Failed to delete all favorites: $error');
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
          title: const Text('Xác nhận xóa'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Bạn có chắc chắn muốn xóa mục này không?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Huỷ'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Khoá học yêu thích',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'deleteAll') {
                deleteAllFavoritesSequentially();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'deleteAll',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Xóa tất cả'),
                ),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
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
