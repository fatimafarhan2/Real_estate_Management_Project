import 'package:flutter/material.dart';
import 'package:real_estate_app/Signup/signup_agent.dart';
import 'package:real_estate_app/Signup/signup_user.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/login/login_screen/loginscreen.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        iconTheme: IconThemeData(color: textColor),
      ),
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
            Signup_button(
              l_str: Text(
                'Signup as User',
                style: tbutton_style,
              ),
              onpress: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupPageUser()));
              },
            ),
            SizedBox(
              height: 30,
            ),
            Signup_button(
              l_str: Text(
                'Signup as Agent',
                style: tbutton_style,
              ),
              onpress: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupPageAgent()));
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

class Signup_button extends StatelessWidget {
  const Signup_button({super.key, required this.l_str, required this.onpress});
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
