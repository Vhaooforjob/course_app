// import 'dart:convert';
// import 'package:http/http.dart' as http;

// final baseUrl = 'http://192.168.1.19:3303/';
// const addressIPv4 = 'http://192.168.1.19';
// const port = '3303';
// final baseUrl = '${addressIPv4}:${port}/';
final baseUrl = 'https://server-course-app.onrender.com/';
final registration = baseUrl + 'api/users/registration';
final login = baseUrl + 'api/users/login';
final courses = baseUrl + 'api/courses/';
final episode = baseUrl + 'api/episodes/';
final search = baseUrl + 'api/search?query=';
final searchU = baseUrl + 'api/search/users?query=';
final searchC = baseUrl + 'api/search/courses?query=';
final fav = baseUrl + 'api/fav/';
final rating = baseUrl + 'api/rate/';
final specialty = '${baseUrl}api/userSpecialty/';
final categories = baseUrl + 'api/coursesCategory/';

String userInfo(String userId) => baseUrl + 'api/users/user/$userId';
String updateUserInfo(String userId) => baseUrl + 'api/users/$userId';
String userCourses(String userId) => baseUrl + 'api/courses/user/$userId';
