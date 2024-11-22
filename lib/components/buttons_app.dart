import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';

class ButtonsApp extends StatefulWidget {
  final Function onTap;
  final Widget det;

  const ButtonsApp({super.key, required this.onTap, required this.det});

  @override
  State<ButtonsApp> createState() => _ButtonsAppState();
}

class _ButtonsAppState extends State<ButtonsApp> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => widget.onTap(),
      child: widget.det,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(200, 50),
        backgroundColor: textColor,
      ),
    );
  }
}
