import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:real_estate_app/Chat/pages/agentchtlogpage.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/login_and_signup/Firebase/Authserviceuser.dart';
import 'package:real_estate_app/login_and_signup/authServices.dart';

class AgentProfile extends StatefulWidget {
  const AgentProfile({super.key});

  @override
  State<AgentProfile> createState() => _AgentProfileState();
}

class _AgentProfileState extends State<AgentProfile> {
  final double ratingFromDb = 4.2;

  String useridfirebase = '';

  Future<void> getCurrentUserId() async {
    var user1 = FirebaseAuth.instance.currentUser; // Get the current user

    if (user1 != null) {
      setState(() {
        useridfirebase = user1.uid;
      });
    } else {
      setState(() {
        useridfirebase = '';
      });
    }
  }

// logout
  void firebaselogout() {
    final auth = AuthServicesUser();
    auth.logout();
  }

// logout
  void Supabaselogout() {
    final auth = Authservices();
    auth.signOut();
  }

  @override
  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    // Fetch properties on initialization
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: scaffoldColor,
          icon: const Icon(Icons.logout), // Logout icon
          onPressed: () {
            Supabaselogout();
            firebaselogout();
          },
        ),
        centerTitle: true,
        title: const Text(
          '  Agent Profile',
          style: tappbar_style,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              //1st row containing image at far right and user details such as info etc
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: 200,
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: boxcolor,
                        border: Border.all(
                          // Add border
                          color: appointmentBoxColor, // Border color
                          width: 5.0, // Border width
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6.0),
                          const Text(
                            '  Agent\n  Information ',
                            style: tUserTitle,
                          ),
                          const Text(
                            '  User Name: [ ]',
                            style: tUserBody,
                          ),
                          const Text(
                            '  Phone Number: [ ]',
                            style: tUserBody,
                          ),
                          const Text(
                            '  Email: [ ]',
                            style: tUserBody,
                          ),
                          const Text(
                            '  Agent Rating:',
                            style: tUserBody,
                          ),
                          RatingBar(
                              initialRating:
                                  ratingFromDb, //will be updated thro database
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 30,
                              ignoreGestures: true,
                              updateOnDrag: true,
                              ratingWidget: RatingWidget(
                                full: const Icon(
                                  Icons.star, // Full icon
                                  color: Color.fromARGB(255, 243, 201, 75),
                                ),
                                half: const Icon(
                                  Icons.star_border, // Half icon
                                  color: Color.fromARGB(255, 243, 201, 75),
                                ),
                                empty: const Icon(
                                  Icons.star_border, // Empty icon
                                  color:
                                      Colors.grey, // Different color for empty
                                ),
                              ),
                              maxRating: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              onRatingUpdate: (rating) {})
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipOval(
                    child: Image.asset(
                      'images/pp1.jpg',
                      height: 160,
                      width: 160,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                  height: 50,
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10.0), // Add vertical padding
              alignment: Alignment.topLeft, // Center the text
              child: const Text(
                ' Appointments',
                style: TextStyle(
                  fontSize: 33,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                  color: buttonColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6.0),
              height: 370,
              width: 390,
              decoration: BoxDecoration(
                color: boxcolor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  // Add border
                  color: appointmentBoxColor, // Border color
                  width: 5.0, // Border width
                ),
              ),
              child: SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 1; i <= 10; i++)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Appointment number : $i ',
                          style: tAppointmentBody,
                        ),
                      )
                  ],
                ),
              )),
            ),
            SizedBox(
              height: 53,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AgentChatLogPage(
                                  agentId: useridfirebase,
                                )),
                      );
                    },
                    icon: const Icon(Icons.person),
                    label: const Text(
                      'Chats',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      iconColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 20.0), // Padding
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      color: buttonColor, // Background color
                      shape: BoxShape.circle, // Makes the background circular
                    ),
                    child: IconButton(
                      onPressed: () {},
                      color: Colors.white, // Icon color
                      icon: const Icon(Icons.house_outlined),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_document),
                    label: const Text(
                      'View Offers',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      iconColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 20.0), // Padding
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
