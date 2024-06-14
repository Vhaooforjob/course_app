import 'dart:convert';
import 'package:http/http.dart' as http;

// final baseUrl = 'http://192.168.1.19:3303/';
// const addressIPv4 = 'http://192.168.1.19';
// const port = '3303';
// final baseUrl = '${addressIPv4}:${port}/';
final baseUrl = 'https://server-course-app.onrender.com/';
final registration = baseUrl + 'api/users/registration';
final login = baseUrl + 'api/users/login';
final courses = baseUrl + 'api/courses/';
String userInfo(String userId) => baseUrl + 'api/users/user/$userId';
