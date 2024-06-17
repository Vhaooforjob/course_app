import 'package:course_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingOtherPage extends StatefulWidget {
  final String userId;

  const SettingOtherPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _SettingOtherPageState createState() => _SettingOtherPageState();
}

class _SettingOtherPageState extends State<SettingOtherPage> {
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('expiryDate');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt khác'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Đăng xuất'),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
