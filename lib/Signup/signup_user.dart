import 'package:flutter/material.dart';
import 'package:real_estate_app/Signup/widget/input_box.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/login_and_signup/Firebase/Authserviceuser.dart';
import 'package:real_estate_app/login_and_signup/authServices.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPageUser extends StatefulWidget {
  const SignupPageUser({super.key});

  @override
  State<SignupPageUser> createState() => _SignupPageUserState();
}

class _SignupPageUserState extends State<SignupPageUser> {
  final TextEditingController userIdController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController phoneNumberController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

//authservice firebase
  final authfireservice = AuthServicesUser();
// authservice supabase
  final authServices = Authservices();

  final storage = Supabase.instance.client.storage;
  String? fPath;
  final SupabaseClient client = Supabase.instance.client;

//extractin url of user's upload image
  Future<String?> fetchImageUrl(String filePath) async {
    try {
      final publicUrl = client.storage
          .from('ProfilePictures') // Bucket name
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error fetching public URL: $e');
      return null;
    }
  }

  File? _imageFile;
//Pick image method
  Future pickImage() async {
    final ImagePicker picker = ImagePicker();

    //Pick from gallery
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
      }
    });
  }

//upload method
// Upload method
  Future<String?> uploadImage() async {
    if (_imageFile == null) return null;

    final fileName =
        DateTime.now().millisecondsSinceEpoch.toString(); // Unique file name
    final path = 'uploads/$fileName'; // Path in the bucket

    try {
      // Upload the file to Supabase storage
      await Supabase.instance.client.storage
          .from('ProfilePictures') // Bucket name
          .upload(path, _imageFile!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
      // Returning the file path
      final url = await storage.from('ProfilePicture').getPublicUrl(path);

      setState(() {
        fPath = url.toString();
      });
      return fPath;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
      return null;
    }
  }

//hash function for pawword
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

  Future<void> showErrorSnackbar(String message, BuildContext context) async {
    if (!mounted) return; // Check if the widget is still in the widget tree

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
        title: const Text('Signup'),
        centerTitle: true,
        backgroundColor: buttonColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Create a New Account',
                  style: TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Center(
                //   child: ElevatedButton.icon(
                //     onPressed: () async {
                //       await pickImage(); // Open image picker
                //       //extracting image url:modified
                //       await uploadImage(); // Upload the image to Supabase
                //       print(fPath);
                //     },
                //     icon: const Icon(Icons.upload),
                //     label: const Text(
                //       'Upload Image',
                //       style: tbutton_style,
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: buttonColor,
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 20, vertical: 10),
                //     ),
                //   ),
                // ),

                // First Name
                const Text('First Name:', style: Tleading_header),
                const SizedBox(height: 5),
                Inputbox(
                    controller: firstNameController,
                    hintText: 'Enter your First Name:'),

                const SizedBox(height: 15),

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
                // Last Name

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

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Placeholder for signup action
                      //supabase signup
                      bool result = await authServices.signUpUserAgent(
                          'user',
                          addressController.text,
                          firstNameController.text,
                          lastNameController.text,
                          phoneNumberController.text,
                          emailController.text,
                          hashPassword(passwordController.text),
                          0,
                          fPath,
                          usernameController.text,
                          context);
                      //firebase signup
                      bool resp = await authfireservice.authenticateUser(
                          email: emailController.text,
                          password: passwordController.text,
                          isLogin: false,
                          role: 'user');
                      if (result == false) {
                        showErrorSnackbar('Error in signing up', context);
                      } else {
                        showErrorSnackbar('Successful in signing up', context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
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
