import 'package:http/http.dart' as http;
import 'dart:convert';
import '../configs/configs.dart';

class APIService {
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
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw error;
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
        if (jsonResponse['status']) {
          return true;
        } else {
          return false;
        }
      } else {
        print('Failed to register: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error registering user: $error');
      throw error;
    }
  }
}
