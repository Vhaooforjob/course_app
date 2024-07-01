import 'package:course_app/services/api_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'home_page.dart';
import 'registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:course_app/configs/colors.dart';

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
        // ignore: unused_local_variable
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
                const SizedBox(height: 100),
                const Text(
                  'HELA COURSES',
                  style: TextStyle(
                      fontSize: 40,
                      color: blue74B4FF,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 100),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.person_2_outlined),
                      color: Colors.black.withOpacity(0.5),
                      onPressed: () {},
                    ),
                    hintText: "Email",
                    errorText:
                        _isNotValidate ? "Email không được để trống" : null,
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
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.lock_outline),
                        color: Colors.black.withOpacity(0.5),
                        onPressed: () {},
                      ),
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
                      errorText: _isNotValidate
                          ? "Mật khẩu không được để trống"
                          : null,
                      hintText: "Mật khẩu",
                      border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
                ),
                const SizedBox(height: 10),
                // const Align(
                //   alignment: Alignment.centerRight,
                //   child: Text(
                //     'Quên mật khẩu?',
                //     style: TextStyle(fontSize: 16, color: grey635C5C),
                //   ),
                // ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: loginUser,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(blue5AB2FF),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 90, vertical: 12),
                    child: Text(
                      'ĐĂNG NHẬP',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationScreen()),
                    );
                  },
                  child: HStack([
                    "Bạn chưa có tài khoản?"
                        .text
                        .size(16)
                        .color(blue378CE7)
                        .make(),
                    " Đăng ký".text.size(16).color(blue004FCA).bold.make()
                  ]).centered(),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
