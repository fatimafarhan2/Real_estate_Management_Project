import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_app/Homepage/mainpage.dart';
import 'package:real_estate_app/Profiles/agent_profile.dart';
import 'package:real_estate_app/Profiles/sub_pages/HireAgent.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewAgent.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewOffers.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewWishlists.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewAgentReviews.dart';
import 'package:real_estate_app/Profiles/user_profile.dart';
import 'package:real_estate_app/Property/propertyView.dart';
import 'package:real_estate_app/Property/subpages/viewComments.dart';
import 'package:real_estate_app/Signup/Signup.dart';
import 'package:real_estate_app/forms/offers_form.dart';
import 'package:real_estate_app/forms/property_details_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:real_estate_app/Profiles/user_profile.dart';
//import 'Profiles/agent_profile.dart';
//import 'Admin/admin.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/login_and_signup/login_signup.dart';

void main() async {
  await Supabase.initialize(
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6aW1lbGRoY25sbGFhZHp2c2p0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjkyNTU4MzMsImV4cCI6MjA0NDgzMTgzM30.a9JsiuMlHzjHuKma0T3TNzcpGQUn6i69R0Yn1H9ntS0',
      url: 'https://xzimeldhcnllaadzvsjt.supabase.co');
  await Firebase.initializeApp();

  runApp(const Realestateapp());
}

class Realestateapp extends StatelessWidget {
  const Realestateapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            //BUTTON COLOR
            primaryColor: buttonColor,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: buttonColor,
              // COMPLEMENTARY SECONDARY ELEMENS LIKE SLIDERS AND ETC
              // secondary: Colors.lightGreen,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: buttonColor, // Directly set FAB color here
            ),
            buttonTheme: ButtonThemeData(
                colorScheme: ColorScheme.fromSwatch()
                    .copyWith(primary: buttonColor, secondary: buttonColor)),
            appBarTheme: const AppBarTheme(
              //APPBAR
              color: buttonColor,
              foregroundColor: buttonColor,
            ),
            //FOR SCAFFOLD
            scaffoldBackgroundColor: scaffoldColor,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: buttonColor),
            )),
        home: const LoginSignUp());
  }
}
