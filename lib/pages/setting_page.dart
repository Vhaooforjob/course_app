import 'package:course_app/pages/user/edit_profile_user_page.dart';
import 'package:course_app/pages/rating/rating_history_page.dart';
import 'package:course_app/pages/setting_other_page.dart';
import 'package:course_app/pages/user/user_detail_page.dart';
import 'package:course_app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:course_app/models/users.model.dart';
import 'package:course_app/services/api_user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:course_app/styles/theme_provider.dart';

class SettingPage extends StatefulWidget {
  final String userId;
  const SettingPage({required this.userId, Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late Future<User> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = _fetchAndCacheUser();
  }

  Future<User> _fetchAndCacheUser() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUser = prefs.getString('user_${widget.userId}');
    if (cachedUser != null) {
      final decodedUser = jsonDecode(cachedUser);
      final user = User.fromJson(decodedUser);
      _futureUser = Future.value(user);
    } else {
      final user = await fetchUserInfo(widget.userId);
      prefs.setString('user_${widget.userId}', jsonEncode(user.toJson()));
      _futureUser = Future.value(user);
    }
    return _futureUser;
  }

  void _refreshUser() async {
    final user = await fetchUserInfo(widget.userId);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_${widget.userId}', jsonEncode(user.toJson()));
    setState(() {
      _futureUser = Future.value(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('', style: AppStyles.headerText),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.grey[850],
      ),
      body: Container(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: FutureBuilder<User>(
          future: _futureUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final user = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                            radius: 30,
                            backgroundImage: user.imageUrl != null
                                ? NetworkImage(user.imageUrl!, scale: 1.0)
                                : const AssetImage(
                                        'assets/images/profile_picture.png')
                                    as ImageProvider),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.fullName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  )),
                              Text(user.email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  )),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const ImageIcon(
                              AssetImage('assets/images/edit_profile.png')),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfileUserPage(userId: widget.userId),
                              ),
                            ).then((value) {
                              if (value == true) {
                                _refreshUser();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SettingOption(
                      icon: Icons.person,
                      text: 'Trang cá nhân',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailPage(
                              userId: widget.userId,
                              userCourseId: widget.userId,
                            ),
                          ),
                        );
                      },
                    ),
                    // SettingOption(
                    //   icon: Icons.book,
                    //   text: 'Lịch sử học',
                    //   isDarkMode: isDarkMode,
                    //   onTap: () {},
                    // ),
                    SettingOption(
                      icon: Icons.star,
                      text: 'Đánh giá',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RatingHistoryPage(userId: widget.userId),
                          ),
                        );
                      },
                    ),
                    SettingOption(
                      icon: Icons.share,
                      text: 'Chia sẻ',
                      isDarkMode: isDarkMode,
                      onTap: () {},
                    ),
                    SettingOption(
                      icon: Icons.settings,
                      text: 'Cài đặt',
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SettingOtherPage(userId: widget.userId),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No user data'));
            }
          },
        ),
      ),
    );
  }
}

class SettingOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isDarkMode;

  const SettingOption({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.isDarkMode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: Row(
          children: [
            Icon(icon, color: isDarkMode ? Colors.white : Colors.blue),
            const SizedBox(width: 18),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  )),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
