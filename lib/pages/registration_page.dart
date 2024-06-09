import 'dart:convert';
import 'dart:math';
import 'package:course_app/configs/configs.dart';
import 'package:course_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_input.dart';
import '../services/api_service.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<RegistrationScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  bool _isPasswordVisible = false;

  void registerUser() async {
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        usernameController.text.isNotEmpty &&
        fullNameController.text.isNotEmpty) {
      var regBody = {
        "email": emailController.text,
        "password": passwordController.text,
        "username": usernameController.text,
        "full_name": fullNameController.text
      };

      var response = await http.post(Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status']) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          _showErrorMessage(jsonResponse['message'] ??
              "Registration failed. Please try again.");
        }
      } else {
        _showErrorMessage("Something went wrong. Please try again.");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(
                controller: usernameController, hintText: "Username"),
            _buildTextField(controller: emailController, hintText: "Email"),
            _buildTextField(
                controller: fullNameController, hintText: "Full name"),
            _buildPasswordTextField(),
            _buildRegisterButton(),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: HStack([
                "Already Registered?".text.make(),
                "Sign In".text.make()
              ]).centered(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String hintText}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          errorStyle: const TextStyle(color: Colors.white),
          errorText: _isNotValidate ? "Enter Proper Info" : null,
          hintText: hintText,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
    ).p4().px24();
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
            icon: const Icon(Icons.password),
            onPressed: () {
              String passGen = generatePassword();
              passwordController.text = passGen;
              setState(() {});
            },
          ),
          filled: true,
          fillColor: Colors.white,
          errorStyle: const TextStyle(color: Colors.white),
          errorText: _isNotValidate ? "Enter Proper Info" : null,
          hintText: "Password",
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
    ).p4().px24();
  }

  Widget _buildRegisterButton() {
    return HStack([
      GestureDetector(
        onTap: () => {registerUser()},
        child: VxBox(child: "Register".text.white.makeCentered().p16())
            .green600
            .roundedLg
            .make()
            .px16()
            .py16(),
      ),
    ]);
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
