import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/components/buttons_app.dart';
import 'package:real_estate_app/login_and_signup/Firebase/Authserviceuser.dart';
import 'package:real_estate_app/login_and_signup/authServices.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class LoginInput extends StatelessWidget {
  LoginInput({super.key, required this.title, required this.role});
  final Text title;
  final String role;
  String hashPassword(String password) {
    // Convert the password to bytes (UTF-8 encoding)
    final bytes = utf8.encode(password);

    // Hash the bytes using SHA-256
    final hashedBytes = sha256Hash(bytes);

    // Convert hashed bytes to a readable hexadecimal string
    return bytesToHex(hashedBytes);
  }

  Uint8List sha256Hash(List<int> bytes) {
    final hash = sha256.convert(bytes);
    return Uint8List.fromList(hash.bytes);
  }

  String bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

//firebase auh service
  final authfireservice = AuthServicesUser();
  //supabse auh service
  final authServices = Authservices();
  Future<void> showErrorSnackbar(String message, BuildContext context) async {
    // Check if the widget is still mounted
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 241, 221),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 55, 88, 11),
              borderRadius: BorderRadius.circular(20),
            ),
            height: 400,
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoginInputButton(
                    inputText: Text('Enter Username or Email')),
                const SizedBox(height: 8),
                OutlineInputButton(
                  controller: emailController,
                  obsc: false,
                ),
                const SizedBox(height: 20),
                const LoginInputButton(inputText: Text('Enter Password')),
                const SizedBox(height: 8),
                OutlineInputButton(
                  controller: passwordController,
                  obsc: true,
                ),
                const SizedBox(height: 20),
                ButtonsApp(
                  onTap: () async {
                    int result = await authServices.loginUser(
                        context,
                        emailController.text,
                        hashPassword(
                          passwordController.text,
                        ),
                        role);
                    //firebase login
                    await authfireservice.authenticateUser(
                        email: emailController.text,
                        password: passwordController.text,
                        isLogin: true,
                        role: role);

                    if (result == 1) //case no user exist as such
                    {
                      showErrorSnackbar('User not found', context);
                    } else if (result == 2) {
                      showErrorSnackbar('Error in logging in', context);
                    } else if (result == 0) {
                      showErrorSnackbar('Successfully logged in', context);
                    } else if (result == 4) {
                      showErrorSnackbar(
                          'Log in failed as you logged in with the incorrect role',
                          context);
                    }
                  },
                  det: const Text(
                    'Submit',
                    style: tbutton_style,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineInputButton extends StatelessWidget {
  const OutlineInputButton(
      {super.key, required this.controller, required this.obsc});

  final TextEditingController controller;
  final bool obsc;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: obsc,
        decoration: const InputDecoration(
          filled: true,
          fillColor: scaffoldColor,
        ),
      ),
    );
  }
}

class LoginInputButton extends StatelessWidget {
  const LoginInputButton({super.key, required this.inputText});
  final Text inputText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(250, 45),
        backgroundColor: scaffoldColor,
        shape: const BeveledRectangleBorder(),
      ),
      child: inputText,
    );
  }
}
