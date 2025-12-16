import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double fontSize;
  final double padding;

  const CustomButton({
    required this.text,
    required this.onTap,
    super.key,
    this.fontSize = 16, // дефолтний розмір шрифту
    this.padding = 12,  // дефолтний відступ
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          // ignore: lines_longer_than_80_chars
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(text, style: TextStyle(fontSize: fontSize)),
      ),
    );
  }
}
