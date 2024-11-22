import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

//common methods
Container propertyHeadingtest(Widget childt) {
  return Container(
      padding: const EdgeInsets.all(33.0), // Add vertical padding
      alignment: Alignment.topLeft, // Center the text
      child: childt);
}

//common methods
Container propertyHeading(Widget childt) {
  return Container(
      padding: const EdgeInsets.all(10.0), // Add vertical padding
      alignment: Alignment.topLeft, // Center the text
      child: childt);
}

Container propertyBox(Widget childb) {
  return Container(
    width: 370,
    height: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: const Color.fromARGB(255, 2, 41, 19),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4), // Shadow color
          blurRadius: 15, // Softness of the shadow
          spreadRadius: 1, // Extend the shadow
          offset: const Offset(10, 10), // Position of the shadow
        ),
      ],
    ),
    child: Center(
      child: childb,
    ),
  );
}

//function for pop-up box of email button
void showEmail(BuildContext context, String email) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 222, 173, 221),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          content: Text(
            email,
            style: const TextStyle(
              color: Color.fromARGB(255, 73, 4, 76),
              fontSize: 25,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); //close dialog box
                },
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Color.fromARGB(255, 73, 4, 76),
                    fontSize: 20,
                  ),
                ))
          ],
        );
      });
}

//function to call
Future<void> callAgent(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    throw 'Could not launch $phoneNumber';
  }
}
