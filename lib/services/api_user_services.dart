import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:course_app/models/users.model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../configs/configs.dart';

Future<User> fetchUserInfo(String userId) async {
  final url = Uri.parse(userInfo(userId));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    print('No token found. Please log in.');
    throw Exception('Authentication token missing');
  }
  print('Fetching user info from: $url');

  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 401) {
    print('Unauthorized. Token may have expired.');
    throw Exception('Unauthorized. Please log in again.');
  } else if (response.statusCode == 404) {
    print('User not found with userId: $userId');
    throw Exception('User not found');
  } else {
    print('Failed to load user. Status code: ${response.statusCode}');
    throw Exception('Failed to load user');
  }
}

Future<bool> updateUser(User user) async {
  final userData = user.toJson();
  userData.removeWhere((key, value) => value == '');

  final url = Uri.parse(updateUserInfo(user.id));
  print('Updating user info at: $url');
  print('User data: ${jsonEncode(user.toJson())}');

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(userData),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print(
        'Failed to update user. Status code: ${response.statusCode}, Response body: ${response.body}');
    return false;
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

Future<bool> verifyCurrentPassword(
    String userId, String currentPassword) async {
  try {
    User user = await fetchUserInfo(userId);

    var reqBody = {"email": user.email, "password": currentPassword};

    var response = await http.post(
      Uri.parse(login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reqBody),
    );

    var jsonResponse = jsonDecode(response.body);
    return jsonResponse['status'] == true;
  } catch (error) {
    print('Failed to verify current password: $error');
    return false;
  }
}
