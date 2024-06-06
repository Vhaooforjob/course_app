import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final token;
  const HomeScreen({@required this.token, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userEmail;
  List? items;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    setState(() {
      userEmail = jwtDecodedToken['email'];
      if (jwtDecodedToken.containsKey('email')) {
        userEmail = jwtDecodedToken['email'];
      } else {
        userEmail = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Email: $userEmail',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Center(
        child: Text('Welcome to Home Screen'),
      ),
    );
  }
}
