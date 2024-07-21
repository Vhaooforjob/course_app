import 'package:course_app/pages/auth/login_page.dart';
import 'package:course_app/pages/user/change_password_user.dart';
import 'package:course_app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        title: const Text('Cài đặt khác', style: AppStyles.headerText),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                Icons.key,
                color: Colors.blue[900],
              ),
              title: const Text('Đổi mật khẩu'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChangePasswordUser(userId: widget.userId),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
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
