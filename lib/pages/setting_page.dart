import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  final String userEmail;

  const SettingPage({required this.userEmail, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/profile_picture.png'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userEmail,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                )
              ],
            ),
            const SizedBox(height: 32),
            SettingOption(
                icon: Icons.person, text: 'Trang cá nhân', onTap: () {}),
            SettingOption(icon: Icons.book, text: 'Lịch sử học', onTap: () {}),
            SettingOption(icon: Icons.star, text: 'Đánh giá', onTap: () {}),
            SettingOption(icon: Icons.share, text: 'Chia sẻ', onTap: () {}),
            SettingOption(icon: Icons.settings, text: 'Cài đặt', onTap: () {}),
          ],
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
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
