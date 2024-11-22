import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/login/login_screen/loginscreen.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldColor,
        // foregroundColor: textColor,
        iconTheme: const IconThemeData(color: textColor),
      ),
      backgroundColor: scaffoldColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(
              flex: 2,
            ),
            Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: buttonColor),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.house_outlined,
                  size: 120,
                  color: scaffoldColor,
                ),
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            const LoginButton(
              lStr: Text(
                'LOGIN AS USER',
                style: tbutton_style,
              ),
              title: Text(
                'USER LOGIN',
                style: tappbar_style,
              ),
              role: 'user',
            ),
            SizedBox(height: 20),
            const LoginButton(
              lStr: Text(
                'LOGIN AS AGENT',
                style: tbutton_style,
              ),
              title: Text(
                'AGENT LOGIN',
                style: tappbar_style,
              ),
              role: 'agent',
            ),
            const SizedBox(height: 20),
            const LoginButton(
              lStr: Text(
                'LOGIN AS ADMIN',
                style: tbutton_style,
              ),
              title: Text(
                'ADMIN LOGIN',
                style: tappbar_style,
              ),
              role: 'admin',
            ),
            const Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton(
      {super.key, required this.lStr, required this.title, required this.role});
  final Text lStr;
  final Text title;
  final String role;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginInput(
                        title: title,
                        role: role,
                      )));
        },
        child: lStr,
        style: ElevatedButton.styleFrom(
            minimumSize: Size(200, 50), backgroundColor: buttonColor));
  }
}
