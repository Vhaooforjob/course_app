import 'package:course_app/models/courses.model.dart';
import 'package:course_app/pages/login_page.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'package:course_app/pages/dashboard_page.dart';
import 'package:course_app/pages/fav_page.dart';
import 'package:course_app/pages/setting_page.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:course_app/widgets/navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({required this.token, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userId;
  late String userEmail;
  // List? items;
  int _selectedIndex = 0;
  List<Widget> _pages = [
    const HomePage(),
    const DashboardPage(),
    const FavPage(),
    const SettingPage(userEmail: ''),
  ];
  @override
  void initState() {
    super.initState();
    if (widget.token.isNotEmpty) {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
      setState(() {
        userId = jwtDecodedToken['_id'] ?? '';
        userEmail = jwtDecodedToken['email'] ?? '';
        _pages = [
          const HomePage(),
          const DashboardPage(),
          const FavPage(),
          SettingPage(userEmail: userEmail),
        ];
      });
    } else {
      _selectedIndex = 0;
      _pages = [
        const HomePage(),
        const DashboardPage(),
        const FavPage(),
        const SettingPage(userEmail: ''),
      ];
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('expiryDate');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: $userEmail',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'UserId: $userId',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBarBuild(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Course>> futureCourses;

  @override
  void initState() {
    super.initState();
    futureCourses = ApiCourseServices.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: futureCourses,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image.network(
                    //   snapshot.data![index].imageUrl,
                    //   height: 80,
                    //   fit: BoxFit.cover,
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        snapshot.data![index].title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        snapshot.data![index].description,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("${snapshot.error}"),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
