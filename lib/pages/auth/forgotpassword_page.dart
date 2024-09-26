// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:course_app/configs/configs.dart';
import 'package:course_app/pages/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:course_app/models/users.model.dart';
import 'package:http/http.dart' as http;
import 'package:course_app/configs/user.json.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  User? _foundUser;
  bool _userFound = false;

  void _findUser() async {
    setState(() {
      _isLoading = true;
      _foundUser = null;
      _userFound = false;
    });

    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Địa chỉ email không hợp lệ')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      List<User> users = await fetchAllUsers();
      User? user =
          users.firstWhere((user) => user.email == email, orElse: () => null!);

      if (user != null) {
        setState(() {
          _foundUser = user;
          _userFound = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Không tìm thấy người dùng với email này')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Địa chỉ email không hợp lệ')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      List<User> users = await fetchAllUsers();
      User? user = users.firstWhere((user) => user.email == email);

      if (user != null) {
        // Tạo mật khẩu mới
        String newPassword = generateRandomPassword();
        print(newPassword);

        // Đổi mật khẩu của người dùng có email đã nhập
        bool success = await updateUserPassword(user.id, newPassword);

        if (success) {
          // Gửi email chứa mật khẩu mới
          await sendEmail(email, newPassword);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Mật khẩu mới đã được gửi đến email của bạn')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật mật khẩu thất bại')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Không tìm thấy người dùng với email này')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> sendEmail(String toEmail, String newPassword) async {
    String username = 'dovanhao883@gmail.com';
    String password = 'esng mijr fyay lace';
    final smtpServer = SmtpServer(
      'smtp.gmail.com',
      port: 587,
      username: username,
      password: password,
      ssl: false,
      ignoreBadCertificate: false,
    );

    // final message = Message()
    //   ..from = Address(username, 'Hela Courses')
    //   ..recipients.add(Address(toEmail))
    //   ..subject = 'Mật khẩu mới của bạn'
    //   ..text = 'Mật khẩu mới của bạn là: $newPassword';
    final message = Message()
      ..from = Address(username, 'Hela Courses')
      ..recipients.add(Address(toEmail))
      ..subject = 'Thông Tin Mật Khẩu Mới'
      ..text = '''
      Chào bạn,

      Mật khẩu mới của bạn là: $newPassword

      Chân thành cảm ơn,
      Đội ngũ Hela Courses
      
      Nếu bạn có bất kỳ câu hỏi nào, vui lòng liên hệ với chúng tôi qua:
      - Điện thoại: 0949847277
      - Email: helacourses@support.com
      ''';
    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
      print('Email sent successfully to $toEmail');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.email, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mật khẩu mới đã được gửi đến email của bạn!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 5));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } on MailerException catch (e) {
      print('Message not sent. ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã gửi thất bại!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }

  Future<List<User>> fetchAllUsers() async {
    final url =
        Uri.parse('https://server-course-app.onrender.com/api/users/user');
    print('Fetching all users from: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      if (responseBody is List) {
        List<UserJson> userJsonList =
            responseBody.map((user) => UserJson.fromJson(user)).toList();
        List<User> userList = userJsonList
            .map((userJson) => User(
                  id: userJson.id,
                  username: userJson.username,
                  email: userJson.email,
                  fullName: userJson.fullName,
                  joinDate: userJson.joinDate,
                  imageUrl: userJson.imageUrl,
                ))
            .toList();
        return userList;
      } else {
        print('Unexpected JSON format: $responseBody');
        throw Exception('Unexpected JSON format');
      }
    } else {
      print('Failed to load users. Status code: ${response.statusCode}');
      throw Exception('Failed to load users');
    }
  }

  Future<bool> updateUserPassword(String userId, String newPassword) async {
    final url = Uri.parse(updateUserInfo(userId));
    print('Updating password for user at: $url');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'password': newPassword}),
    );

    if (response.statusCode == 200) {
      print('Password updated successfully');
      return true;
    } else {
      print(
          'Failed to update password. Status code: ${response.statusCode}, Response body: ${response.body}');
      return false;
    }
  }

  void _showUserDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.imageUrl != null) Image.network(user.imageUrl!),
              const SizedBox(height: 10),
              Text('Fullname: ${user.fullName}'),
              Text('Email: ${user.email}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  String generateRandomPassword() {
    const int passwordLength = 12;
    const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String digits = '0123456789';

    final String allChars = lowercaseChars + uppercaseChars + digits;

    final String password = [
          lowercaseChars,
          uppercaseChars,
          digits,
        ]
            .map((chars) =>
                chars[DateTime.now().millisecondsSinceEpoch % chars.length])
            .join() +
        String.fromCharCodes(Iterable.generate(
            passwordLength - 4,
            (_) => allChars.codeUnitAt(
                DateTime.now().millisecondsSinceEpoch % allChars.length)));

    return (password.split('')..shuffle()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Quên mật khẩu', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tìm kiếm người dùng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nhập email để tìm kiếm người dùng',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                if (_foundUser != null) const SizedBox(height: 24),
                if (_foundUser != null)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: _foundUser!.imageUrl != null &&
                              _foundUser!.imageUrl!.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(_foundUser!.imageUrl!),
                            )
                          : CircleAvatar(
                              child: Text(_foundUser!.fullName[0]),
                            ),
                      title: Text(
                        _foundUser!.fullName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _foundUser!.username,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_userFound ? _resetPassword : _findUser),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004FCA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Text(
                      _isLoading
                          ? "ĐANG XỬ LÝ..."
                          : (_userFound ? "GỬI MẬT KHẨU MỚI" : "TÌM KIẾM"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (_userFound) const SizedBox(height: 16),
                if (_userFound)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _userFound = false;
                          _foundUser = null;
                          _emailController.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Text(
                        "TÌM KIẾM LẠI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
