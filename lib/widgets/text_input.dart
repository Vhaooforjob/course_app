import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final String label;
  final bool isPassword;

  TextInput(
      {required this.label,
      this.isPassword = false,
      required TextEditingController controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }
}
