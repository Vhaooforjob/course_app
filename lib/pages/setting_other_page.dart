import 'package:course_app/pages/auth/forgotpassword_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:course_app/pages/auth/login_page.dart';
import 'package:course_app/pages/user/change_password_user.dart';
import 'package:course_app/styles/styles.dart';
import 'package:course_app/styles/theme_provider.dart';

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
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt khác', style: AppStyles.headerText),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: isDarkMode ? Colors.white : Colors.black,
            iconSize: 20,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                color: isDarkMode ? Colors.white : Colors.blue[900],
              ),
              title: const Text('Chế độ tối'),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (bool value) {
                  themeProvider
                      .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Chế độ tối đã được bật'
                          : 'Chế độ tối đã được tắt'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(
                Icons.key,
                color: isDarkMode ? Colors.white : Colors.blue[900],
              ),
              title: const Text('Đổi mật khẩu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChangePasswordUser(userId: widget.userId),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(
                Icons.key_off_sharp,
                color: isDarkMode ? Colors.white : Colors.blue[900],
              ),
              title: const Text('Quên mật khẩu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Đăng xuất'),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
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
}
