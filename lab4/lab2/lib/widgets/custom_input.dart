import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final double fontSize;
  final double padding;

  const CustomInput({
    required this.hint, super.key,
    this.controller,
    this.obscure = false,
    this.fontSize = 16,
    this.padding = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: TextField(
        controller: controller,   // ← додали
        obscureText: obscure,
        style: TextStyle(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
