import 'package:flutter/material.dart';
import 'package:course_app/models/users.model.dart';
import 'package:course_app/services/api_user_services.dart';

class SettingPage extends StatelessWidget {
  final String userId;
  const SettingPage({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User>(
        future: fetchUserInfo(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.imageUrl != null
                        ? NetworkImage(user.imageUrl!)
                        : AssetImage('assets/profile_picture.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Username: ${user.username}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Email: ${user.email}',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 32),
                  SettingOption(
                      icon: Icons.person, text: 'Trang cá nhân', onTap: () {}),
                  SettingOption(
                      icon: Icons.book, text: 'Lịch sử học', onTap: () {}),
                  SettingOption(
                      icon: Icons.star, text: 'Đánh giá', onTap: () {}),
                  SettingOption(
                      icon: Icons.share, text: 'Chia sẻ', onTap: () {}),
                  SettingOption(
                      icon: Icons.settings, text: 'Cài đặt', onTap: () {}),
                ],
              ),
            );
          } else {
            return Center(child: Text('No user data'));
          }
        },
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
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
