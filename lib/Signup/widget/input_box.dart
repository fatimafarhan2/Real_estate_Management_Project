import 'package:flutter/material.dart';

class Inputbox extends StatelessWidget {
  const Inputbox({
    super.key,
    required this.hintText,
    required this.controller,
    this.fillColor = const Color.fromARGB(255, 147, 153, 97),
  });

  final String hintText;
  final TextEditingController controller;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}