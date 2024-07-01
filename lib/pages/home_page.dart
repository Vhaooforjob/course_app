// ignore_for_file: unused_import
import 'package:carousel_slider/carousel_slider.dart';
import 'package:course_app/models/categories.model.dart';
import 'package:course_app/models/courses.model.dart';
import 'package:course_app/pages/course_detail_page.dart';
import 'package:course_app/pages/course_list_byCate_page.dart';
import 'package:course_app/pages/course_list_page.dart';
import 'package:course_app/pages/login_page.dart';
import 'package:course_app/pages/search_page.dart';
import 'package:course_app/services/api_categories_services.dart';
import 'package:course_app/services/api_course_services.dart';
import 'package:course_app/services/api_user_services.dart';
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
  String? userFullName;
  // List? items;
  int _selectedIndex = 0;
  List<Widget> _pages = [
    const HomePage(
      userId: '',
    ),
    const DashboardPage(
      userId: '',
    ),
    const FavPage(
      userId: '',
    ),
    const SettingPage(
      userId: '',
    ),
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
          HomePage(userId: userId),
          DashboardPage(userId: userId),
          FavPage(userId: userId),
          SettingPage(userId: userId),
        ];
      });
      fetchUserInfo(userId).then((user) {
        setState(() {
          userFullName = user.fullName;
        });
      }).catchError((error) {
        print('Error fetching user info: $error');
      });
    } else {
      _selectedIndex = 0;
      _pages = [
        const HomePage(userId: ''),
        const DashboardPage(userId: ''),
        const FavPage(userId: ''),
        const SettingPage(
          userId: '',
        ),
      ];
    }
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
    const double appBarHeight = 70.0;
    return Scaffold(
      appBar: _selectedIndex == 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(appBarHeight),
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xFF20A2FA),
                title: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                'Chào mừng $userFullName,',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 0),
                              child: Text(
                                'Sẵn sàng học tập thôi nào!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Image(
                          image: AssetImage('assets/images/search_icon.png'),
                          width: 24,
                          height: 24,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchPage(
                                userId: userId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_selectedIndex == 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 165.0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF20A2FA),
                      Colors.white,
                    ],
                    stops: [0.5, 1.0],
                  ),
                ),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 165.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: [
                    'https://i.ibb.co/z40kmFK/carousel.png',
                    'https://i.ibb.co/fpBDfT0/image1.jpg',
                    'https://i.ibb.co/c2J7ZMy/image2.jpg',
                  ].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            image: DecorationImage(
                              image: NetworkImage(i),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 84,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: NavigationBarBuild(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Course>> futureCourses;
  late Future<List<Categories>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCourses = ApiCourseServices.fetchCourses();
    futureCategories = ApiCategoryServices.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: futureCourses,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 200.0),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'CÁC KHÓA HỌC THEO CHỦ ĐỀ',
                            style: TextStyle(
                              color: Color(0xFF004FCA),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: FutureBuilder<List<Categories>>(
                          future: futureCategories,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                height: 80.0,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: snapshot.data!.map((category) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CourseListByCate(
                                                userId: widget.userId,
                                                categoryId: category.id,
                                                categoryName:
                                                    category.categoryName,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Chip(
                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  category.categoryName,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF3F3F3F),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Image.network(
                                                  category.img ?? '',
                                                  width: 24,
                                                  height: 24,
                                                ),
                                              ],
                                            ),
                                            backgroundColor: Colors.transparent,
                                            shape: const StadiumBorder(
                                              side: BorderSide(
                                                  color: Colors.transparent),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
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
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'CÁC KHÓA HỌC NỔI BẬT',
                            style: TextStyle(
                              color: Color(0xFF004FCA),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseList(userId: widget.userId),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'Xem thêm',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final course = snapshot.data![index];
                      return InkWell(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      const SizedBox(height: 4.0),
                                      Text(
                                        course.userId['full_name'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF979797),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
