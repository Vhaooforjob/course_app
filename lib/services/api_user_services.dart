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
