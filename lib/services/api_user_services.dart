import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:course_app/models/users.model.dart';
import '../configs/configs.dart';

Future<User> fetchUserInfo(String userId) async {
  final url = Uri.parse(userInfo(userId));
  print('Fetching user info from: $url');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
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
