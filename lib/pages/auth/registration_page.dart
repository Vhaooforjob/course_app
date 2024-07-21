import 'dart:math';
import 'package:course_app/pages/auth/login_page.dart';
import 'package:course_app/services/api_auth_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:course_app/configs/colors.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<RegistrationScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isNotValidate = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void registerUser() async {
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        fullNameController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty) {
      if (passwordController.text != confirmPasswordController.text) {
        _showErrorMessage("Mật khẩu không trùng nhau");
        return;
      }
      bool isSuccess = await ApiAuthServices.registerUser(
          emailController.text,
          usernameController.text,
          passwordController.text,
          fullNameController.text);

      if (isSuccess) {
        Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        _showErrorMessage("Đăng ký thất bại. Vui lòng thử lại sau.");
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/login_page.png"),
                        fit: BoxFit.cover)),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 40),
                        const Text(
                          'HELA COURSES',
                          style: TextStyle(
                              fontSize: 40,
                              color: blue74B4FF,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: usernameController,
                          labelText: "Tên tài khoản",
                          prefixIcon: const Icon(Icons.person_2_outlined),
                          iconOpacity: 0.5,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: emailController,
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.book_outlined),
                          iconOpacity: 0.5,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: fullNameController,
                          labelText: "Họ và tên",
                          prefixIcon: const Icon(Icons.person_2_outlined),
                          iconOpacity: 0.5,
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordTextField(),
                        const SizedBox(height: 20),
                        _buildConfirmPasswordTextField(),
                        const SizedBox(height: 20),
                        _buildRegisterButton(),
                        const SizedBox(height: 40),
                        Wrap(alignment: WrapAlignment.center, children: [
                          "Bằng cách nhấn vào ".text.color(grey7C7C7C).make(),
                          "'Đăng ký'".text.color(blue004FCA).bold.make(),
                          ", bạn đồng ý với ".text.color(grey7C7C7C).make(),
                          " Điều khoản sử dụng "
                              .text
                              .color(blue004FCA)
                              .bold
                              .make(),
                          "và ".text.color(grey7C7C7C).make(),
                          "Chính sách quyền riêng tư "
                              .text
                              .color(blue004FCA)
                              .bold
                              .make(),
                          "của chúng tôi.".text.color(grey7C7C7C).make(),
                        ]).centered(),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          child: HStack([
                            "Bạn đã có tài khoản?"
                                .text
                                .size(16)
                                .color(blue378CE7)
                                .make(),
                            " Đăng nhập"
                                .text
                                .size(16)
                                .color(blue004FCA)
                                .bold
                                .make()
                          ]).centered(),
                        )
                      ],
                    ),
                  ),
                ))));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    Widget? prefixIcon,
    required double iconOpacity,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          errorText: _isNotValidate ? "Không được để trống" : null,
          labelText: labelText,
          prefixIcon: Opacity(
            opacity: iconOpacity,
            child: prefixIcon,
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: passwordController,
      obscureText: !_isPasswordVisible,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.lock_outline),
            color: Colors.black.withOpacity(0.5),
            onPressed: () {
              String passGen = generatePassword();
              passwordController.text = passGen;
              setState(() {});
            },
          ),
          filled: true,
          fillColor: Colors.white,
          errorText: _isNotValidate ? "Mật khẩu không được để trống" : null,
          hintText: "Mật khẩu",
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextField(
      controller: confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.lock_outline),
            color: Colors.black.withOpacity(0.5),
            onPressed: () {},
          ),
          filled: true,
          fillColor: Colors.white,
          errorText: _isNotValidate ? "Mật khẩu không được để trống" : null,
          hintText: "Nhập lại mật khẩu",
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: registerUser,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(blue5AB2FF),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 110, vertical: 12),
        child: Text(
          'ĐĂNG KÝ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

String generatePassword() {
  const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const String lower = 'abcdefghijklmnopqrstuvwxyz';
  const String numbers = '1234567890';
  const String symbols = '!@#\$%^&*()<>,./';

  String password = '';

  const int passLength = 20;

  String seed = upper + lower + numbers + symbols;

  List<String> list = seed.split('').toList();

  Random rand = Random();

  for (int i = 0; i < passLength; i++) {
    int index = rand.nextInt(list.length);
    password += list[index];
  }
  return password;
}
