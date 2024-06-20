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
      });
    }).catchError((error) {
      print('Failed to remove favorite: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove favorite: $error'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khoá học yêu thích'),
      ),
      body: FutureBuilder<List<Favorite>>(
        future: futureFavorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorites found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final favorite = snapshot.data![index];
                final course = favorite.course;
                return ListTile(
                  leading: SizedBox(
                    width: 100.0,
                    height: 50.0,
                    child: Image.network(
                      course.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(course.title),
                  // subtitle: Text('Favorite ID: ${favorite.id}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailPage(
                          courseId: course.id,
                          userId: '',
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => removeFavorite(favorite.id),
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
