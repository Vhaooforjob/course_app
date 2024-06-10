import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../configs/configs.dart';

class ApiAuthServices {
  static Future<bool> loginUser(String email, String password) async {
    try {
      var reqBody = {"email": email, "password": password};

      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', jsonResponse['token']);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception('Failed to login user: $error');
    }
  }

  static Future<bool> registerUser(
    String email,
    String username,
    String password,
    String fullName,
  ) async {
    var reqBody = {
      "email": email,
      "username": username,
      "password": password,
      "full_name": fullName
    };

    try {
      var response = await http.post(
        Uri.parse(registration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['status'];
      } else {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error registering user: $error');
    }
  }
}
