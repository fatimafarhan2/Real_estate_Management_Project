import 'package:flutter/material.dart';
import 'package:real_estate_app/Signup/widget/input_box.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/login_and_signup/Firebase/Authserviceuser.dart';
import 'package:real_estate_app/login_and_signup/authServices.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class SignupPageAgent extends StatefulWidget {
  @override
  State<SignupPageAgent> createState() => _SignupPageAgentState();
}

class _SignupPageAgentState extends State<SignupPageAgent> {
  final TextEditingController userIdController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController phoneNumberController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  //authservice firebase
  final authfireservice = AuthServicesUser();

  //supabase auth service
  final authServices = Authservices();

  //hash function for password
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hashedBytes = sha256Hash(bytes);
    return bytesToHex(hashedBytes);
  }

  Uint8List sha256Hash(List<int> bytes) {
    final hash = sha256.convert(bytes);
    return Uint8List.fromList(hash.bytes);
  }

  String bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> showErrorSnackbar(String message, BuildContext context) async {
    // Ensure that the widget is still mounted before showing snackbar
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text('Signup', style: tappbar_style),
        centerTitle: true,
        backgroundColor: buttonColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Create a New Account',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // First Name
                const Text('First Name:', style: Tleading_header),
                const SizedBox(height: 5),
                Inputbox(
                    controller: firstNameController,
                    hintText: 'Enter your First Name:'),

                const SizedBox(height: 15),

                // Last Name
                const Text('Last Name:', style: Tleading_header),
                Inputbox(
                    controller: lastNameController,
                    hintText: 'Enter your Last Name:'),

                const SizedBox(height: 15),

                // Address
                const Text('Address', style: Tleading_header),
                const SizedBox(height: 5),
                Inputbox(
                    controller: addressController,
                    hintText: 'Enter your Address:'),

                const SizedBox(height: 15),

                // Phone Number
                const Text('Phone Number:', style: Tleading_header),
                Inputbox(
                    controller: phoneNumberController,
                    hintText: 'Enter your Phone Number'),

                const SizedBox(height: 15),
                // Username
                const Text('Username:', style: Tleading_header),
                const SizedBox(height: 5),
                Inputbox(
                    controller: usernameController,
                    hintText: 'Enter your Username'),

                const SizedBox(height: 15),

                // Email
                const Text('Email:', style: Tleading_header),
                const SizedBox(height: 5),
                Inputbox(
                    controller: emailController, hintText: 'Enter your Email'),

                const SizedBox(height: 15),

                // Password
                const Text('Password:', style: Tleading_header),
                const SizedBox(height: 5),
                Inputbox(
                    controller: passwordController,
                    hintText: 'Enter your Password'),

                const SizedBox(height: 25),
                // Price
                const Text('Price:', style: Tleading_header),
                const SizedBox(height: 5),
                Inputbox(
                    controller: priceController,
                    hintText: 'Enter your Hiring Fees'),
                const SizedBox(height: 25),
                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Placeholder for signup action
                      bool result = await authServices.signUpUserAgent(
                        'agent',
                        addressController.text,
                        firstNameController.text,
                        usernameController.text,
                        lastNameController.text,
                        phoneNumberController.text,
                        emailController.text,
                        hashPassword(passwordController.text),
                        double.parse(priceController.text),
                        context,
                      );
                      // Firebase signup
                      await authfireservice.authenticateUser(
                        email: emailController.text,
                        password: passwordController.text,
                        isLogin: false,
                        role: 'agent',
                      );

                      // Check if the widget is still mounted before showing the snackbar
                      if (!mounted) return;

                      // Use the showErrorSnackbar function to display success or failure message
                      if (result == false) {
                        showErrorSnackbar('Error in signing up', context);
                      } else {
                        showErrorSnackbar('Successful in signing up', context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      backgroundColor: buttonColor,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: tbutton_style,
                    ),
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
