import 'package:course_app/pages/setting_other_page.dart';
import 'package:course_app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:course_app/services/api_user_services.dart' as api_services;
import 'package:course_app/configs/configs.dart';

class ChangePasswordUser extends StatefulWidget {
  final String userId;

  const ChangePasswordUser({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _ChangePasswordUserState createState() => _ChangePasswordUserState();
}

class _ChangePasswordUserState extends State<ChangePasswordUser> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  bool _isCurrentPasswordCorrect = false;
  bool _isCheckingPassword = false;

  Future<void> _checkCurrentPassword() async {
    setState(() {
      _isCheckingPassword = true;
    });

    try {
      bool isCorrect = await api_services.verifyCurrentPassword(
          widget.userId, _currentPasswordController.text);

      setState(() {
        _isCurrentPasswordCorrect = isCorrect;
        _isCheckingPassword = false;
      });

      if (isCorrect) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu hiện tại chính xác')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu hiện tại không đúng')),
        );
      }
    } catch (e) {
      print('Error verifying password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi kiểm tra mật khẩu')),
      );
      setState(() {
        _isCheckingPassword = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Đổi mật khẩu", style: AppStyles.headerText),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                obscureText: true,
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: "Mật khẩu hiện tại",
                  labelStyle: const TextStyle(color: Color(0xFFC1C1C1)),
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Color(0xFFC1C1C1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFC1C1C1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFC1C1C1)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_isCurrentPasswordCorrect)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isCheckingPassword ? null : _checkCurrentPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004FCA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Text(
                      _isCheckingPassword
                          ? "ĐANG KIỂM TRA..."
                          : "XÁC NHẬN MẬT KHẨU",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
              if (_isCurrentPasswordCorrect) ...[
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu mới",
                    labelStyle: const TextStyle(color: Color(0xFFC1C1C1)),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFFC1C1C1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC1C1C1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC1C1C1)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  controller: _confirmNewPasswordController,
                  decoration: InputDecoration(
                    labelText: "Xác nhận mật khẩu mới",
                    labelStyle: const TextStyle(color: Color(0xFFC1C1C1)),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFFC1C1C1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC1C1C1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC1C1C1)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu mới';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final newPassword = _newPasswordController.text;
                        final success = await updateUserPassword(
                            widget.userId, newPassword);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Cập nhật mật khẩu thành công')));
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingOtherPage(
                                userId: widget.userId,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Cập nhật mật khẩu thất bại')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004FCA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      "CẬP NHẬT",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
