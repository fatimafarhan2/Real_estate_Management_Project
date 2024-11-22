import 'package:flutter/material.dart';
import 'package:real_estate_app/Signup/Signup.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/login/login.dart';
import 'package:real_estate_app/login/login_screen/loginscreen.dart';

class LoginSignUp extends StatelessWidget {
  const LoginSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(
              flex: 2,
            ),
            Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: buttonColor),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.house_outlined,
                  size: 120,
                  color: scaffoldColor,
                ),
              ),
            ),
            Spacer(
              flex: 1,
            ),
            main_page(
              l_str: Text(
                'Login',
                style: tbutton_style,
              ),
              onpress: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
            ),
            SizedBox(
              height: 30,
            ),
            main_page(
              l_str: Text(
                'Sign Up',
                style: tbutton_style,
              ),
              onpress: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Signup()));
              },
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class main_page extends StatelessWidget {
  const main_page({super.key, required this.l_str, required this.onpress});
  final Text l_str;
  final onpress;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onpress,
        child: l_str,
        style: ElevatedButton.styleFrom(
            minimumSize: Size(200, 50), backgroundColor: buttonColor));
  }
}