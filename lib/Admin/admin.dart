import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/display_screen/view_request.dart';
import 'package:real_estate_app/Admin/display_screen/viewagent.dart';
import 'package:real_estate_app/Admin/display_screen/viewbuyer.dart';
import 'package:real_estate_app/Admin/display_screen/viewproperty.dart';
import 'package:real_estate_app/Admin/display_screen/viewagentreports.dart';
import 'package:real_estate_app/Admin/display_screen/viewpropertyreports.dart';
import 'package:real_estate_app/Admin/display_screen/viewseller.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: iconColor),
        centerTitle: true,
        title: Text(
          'ADMIN',
          style: tappbar_style,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Padding around the content
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20), // Spacing at the top
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: containers_admin(
                      str: Text(
                        'View Buyer List',
                        style: tbody_style,
                        textAlign: TextAlign.center,
                      ),
                      onpress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewBuyer()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: containers_admin(
                      str: Text(
                        'View Seller List',
                        style: tbody_style,
                        textAlign: TextAlign.center,
                      ),
                      onpress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewSellers()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10), // Vertical spacing between rows
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: containers_admin(
                      str: Text(
                        'View Property List',
                        style: tbody_style,
                        textAlign: TextAlign.center,
                      ),
                      onpress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewProperties()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: containers_admin(
                      str: Text(
                        'View Agent List',
                        style: tbody_style,
                        textAlign: TextAlign.center,
                      ),
                      onpress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewAgents()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: containers_admin(
                      str: Text(
                        'View Request List',
                        style: tbody_style,
                        textAlign: TextAlign.center,
                      ),
                      onpress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewPropertyReports()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: containers_admin(
                      str: Text(
                        'View Reports',
                        style: tbody_style,
                        textAlign: TextAlign.center,
                      ),
                      onpress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewAgentReports()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: containers_admin(
                      str: Text(
                        'View Request List',
                        style: tbody_style,
                        textAlign: TextAlign.center,
                      ),
                      onpress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewRequest()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // only one  buttone
              //wrap the button in tooltip
              //  Tooltip(
              //   message: 'Report Agent',
              //   waitDuration: const Duration(milliseconds: 500),
              //   showDuration: const Duration(seconds: 2),
              //   child: IconButton(
              //       onPressed: () {},
              //       icon: const Icon(
              //         Icons.report,
              //         size: 45,
              //         color: buttonColor,
              //       )),
              // ),
              SizedBox(height: 20), // Vertical spacing at the bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  admin_button(
                    str2: Text(
                      'REPORT',
                      style: tbutton_style,
                    ),
                  ),
                  admin_button(
                    str2: Text(
                      'REMOVE',
                      style: tbutton_style,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom button widget
class admin_button extends StatelessWidget {
  const admin_button({super.key, required this.str2});
  final Text str2;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: str2,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}

// Custom container widget
class containers_admin extends StatelessWidget {
  const containers_admin({super.key, required this.str, required this.onpress});
  final Text str;
  final VoidCallback onpress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpress,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: boxcolor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(20.0),
        child: Center(child: str), // Center the text in the container
      ),
    );
  }
}
