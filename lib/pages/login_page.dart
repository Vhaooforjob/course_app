import 'dart:convert';
import 'package:course_app/configs/configs.dart';
import 'package:course_app/services/api_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_input.dart';
import 'home_page.dart';
import 'registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  bool _isPasswordVisible = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      bool isSuccess = await ApiAuthServices.loginUser(
          emailController.text, passwordController.text);

      if (isSuccess) {
        String myToken = prefs.getString('token')!;
        print('Token: $myToken');
        Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(myToken);
        var expiryDate = JwtDecoder.getExpirationDate(myToken);
        prefs.setString('token', myToken);
        prefs.setString('expiryDate', expiryDate.toIso8601String());
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(token: myToken)));
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid email or password.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Email Sign-In',
                  style: TextStyle(fontSize: 22, color: Colors.blue),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    errorText: _isNotValidate ? "Enter Proper Info" : null,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: const TextStyle(color: Colors.white),
                      errorText: _isNotValidate ? "Enter Proper Info" : null,
                      hintText: "Password",
                      border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loginUser,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.green[600]),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationScreen()),
                    );
                  },
                  child: const Text(
                    'Create a new Account..! Sign Up',
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // final TextEditingController emailController = TextEditingController();
  // final TextEditingController passwordController = TextEditingController();
  // String? errorMessage;

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Login'),
  //     ),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           TextInput(label: 'Email', controller: emailController),
  //           TextInput(
  //             label: 'Password',
  //             isPassword: true,
  //             controller: passwordController,
  //           ),
  //           if (errorMessage != null)
  //             Text(
  //               errorMessage!,
  //               style: TextStyle(color: Colors.red),
  //             ),
  //           CustomButton(
  //             label: 'Login',
  //             onPressed: () async {
  //               setState(() {
  //                 errorMessage = null;
  //               });
  //               try {
  //                 bool success = await APIService.loginUser(
  //                   emailController.text,
  //                   passwordController.text,
  //                 );
  //                 if (success) {
  //                   Navigator.pushReplacement(
  //                     context,
  //                     MaterialPageRoute(builder: (context) => HomeScreen()),
  //                   );
  //                 } else {
  //                   setState(() {
  //                     errorMessage = 'Invalid email or password';
  //                   });
  //                 }
  //               } catch (error) {
  //                 setState(() {
  //                   errorMessage = 'An error occurred. Please try again later.';
  //                 });
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
