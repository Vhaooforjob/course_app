import 'package:course_app/pages/edit_profile_user_page.dart';
import 'package:course_app/pages/rating_history_page.dart';
import 'package:course_app/pages/setting_other_page.dart';
import 'package:course_app/pages/user_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:course_app/models/users.model.dart';
import 'package:course_app/services/api_user_services.dart';

class SettingPage extends StatefulWidget {
  final String userId;
  const SettingPage({required this.userId, Key? key}) : super(key: key);
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // ignore: unused_field
  late Future<User> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = fetchUserInfo(widget.userId);
  }

  void _refreshUser() {
    setState(() {
      _futureUser = fetchUserInfo(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<User>(
          future: fetchUserInfo(widget.userId),
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
                              ? NetworkImage(
                                  user.imageUrl!,
                                  scale: 1.0,
                                )
                              : const AssetImage(
                                      'assets/images/profile_picture.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                user.email,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const ImageIcon(
                            AssetImage('assets/images/edit_profile.png'),
                          ),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailPage(userId: widget.userId),
                          ),
                        );
                      },
                    ),
                    SettingOption(
                      icon: Icons.book,
                      text: 'Lịch sử học',
                      onTap: () {},
                    ),
                    SettingOption(
                      icon: Icons.star,
                      text: 'Đánh giá',
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
                      onTap: () {},
                    ),
                    SettingOption(
                      icon: Icons.settings,
                      text: 'Cài đặt',
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

  const SettingOption(
      {required this.icon, required this.text, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 18),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 16)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
