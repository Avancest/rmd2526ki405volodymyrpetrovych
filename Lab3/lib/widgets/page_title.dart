import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final String title;
  final double fontSize;

  const PageTitle({
    required this.title,
    this.fontSize = 28, // дефолтне значення
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }
}
