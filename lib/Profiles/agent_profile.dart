import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:real_estate_app/Chat/pages/agentchtlogpage.dart';
import 'package:real_estate_app/Homepage/homepage.dart';
import 'package:real_estate_app/Profiles/sub_pages/AgentProfileUPdated.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewOffers.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/login_and_signup/Firebase/Authserviceuser.dart';
import 'package:real_estate_app/login_and_signup/authServices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Navigator done

class AgentProfile extends StatefulWidget {
  const AgentProfile({super.key});

  @override
  State<AgentProfile> createState() => _AgentProfileState();
}

class _AgentProfileState extends State<AgentProfile> {
  final double ratingFromDb = 4.2;

  final SupabaseClient client = Supabase.instance.client;
  List<Map<String, dynamic>> properties = [];
  List<Map<String, dynamic>> agentinfo = [];
  List<Map<String, dynamic>> appointments =
      []; // New list to hold appointment data
  double price = 0.0;
  String username = '';
  String phoneNumber = '';
  String email = '';
  String useridfirebase = '';
  String agentid = '';

  Future<void> getCurrentUser() async {
    try {
      // Get the current user from Supabase
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        agentid = user.id;
        print("Current User ID: ${user.id}");
      } else {
        print("No user is currently logged in.");
      }
    } catch (e) {
      print("Error fetching current user: $e");
      return null;
    }
  }

  Future<void> fetchAgentInfo() async {
    try {
      final data = await client.from('agent').select().eq('agent_id', agentid);

      if (data == null || data.isEmpty) {
        print('No agent information found.');
      } else {
        setState(() {
          print(data);
          agentinfo = List<Map<String, dynamic>>.from(data);

          username = agentinfo[0]['username'] ?? 'No Username';
          price = agentinfo[0]['price'] ?? 0.0;
          phoneNumber = agentinfo[0]['phone_number'] ?? 'No Phone Number';
          email = agentinfo[0]['email'] ?? 'No Email';
        });
      }
    } catch (e) {
      print('Error fetching agent information: $e');
    }
  }

  Future<void> fetchAgentProperties() async {
    try {
      final data = await client.from('properties').select('''
          title,
          price,
          status,
          category:property_category (
            category_name
          )
        ''').eq('agent_id', agentid);

      if (data == null || data.isEmpty) {
        print('No properties found for this agent.');
      } else {
        setState(() {
          print(data);
          properties = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetching agent properties: $e');
    }
  }

  Future<void> fetchAppointments() async {
    try {
      final data = await client
          .from('appointments')
          .select('date, buyer_id, meetaddress')
          .eq('agent_id', agentid);

      if (data == null || data.isEmpty) {
        print('No appointments found for this agent.');
      } else {
        setState(() {
          print(data);
          appointments = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetching appointments: $e');
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
  void initState() {
    super.initState();
    getCurrentUser();
    fetchAgentInfo();
    fetchAgentProperties();
    fetchAppointments(); // Fetch appointments data
  }

  @override
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
        actions: [
ElevatedButton.icon(
                    onPressed: (){
              Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AgentProfileUpdatePage()
                        // for refresh
                        ),
                  );
    },
                    label:const Text( 'Update Profile',style: tbutton_style,),
                  
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                    ),

                  )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
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
                        color: appointmentBoxColor,
                        width: 5.0,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6.0),
                            const Text('  Agent\n  Information ',
                                style: tUserTitle),
                            Text('  Username: $username', style: tUserBody),
                            Text('  Phone Number: $phoneNumber',
                                style: tUserBody),
                            Text('  Email: $email', style: tUserBody),
                            Text('  Price: $price', style: tUserBody),
                            const Text('  Agent Rating:', style: tUserBody),
                            RatingBar(
                              initialRating: ratingFromDb,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 30,
                              ignoreGestures: true,
                              ratingWidget: RatingWidget(
                                full: const Icon(Icons.star,
                                    color: Color.fromARGB(255, 243, 201, 75)),
                                half: const Icon(Icons.star_half,
                                    color: Color.fromARGB(255, 243, 201, 75)),
                                empty: const Icon(Icons.star_border,
                                    color: Colors.grey),
                              ),
                              maxRating: 5,
                              onRatingUpdate: (rating) {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipOval(
                    child:
                        Image.asset('images/pp1.jpg', height: 160, width: 160),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              alignment: Alignment.topLeft,
              child: const Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 33,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700,
                  color: buttonColor,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: boxcolor,
                border: Border.all(width: 5.0, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: 300,
              width: 500,
              child: SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: appointments.map((appointment) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Date: ${appointment['date']} \nBuyer: ${appointment['buyer_id']} \nLocation: ${appointment['meetaddress']}',
                        style: tAppointmentBody,
                      ),
                    );
                  }).toList(),
                ),
              )),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: const Text('Properties',
                  style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w700,
                      color: buttonColor)),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: boxcolor,
                  border: Border.all(width: 5.0, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                height: 300,
                width: 500,
                child: ListView.builder(
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: buttonColor,
                      margin: const EdgeInsets.all(8.0),
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Property: ${properties[index]['title']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.0,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            Text('Status: ${properties[index]['status']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.0,
                                    color: Colors.white)),
                            Text('Price: \$${properties[index]['price']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.0,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                          vertical: 16.0, horizontal: 20.0),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: buttonColor,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewOffers(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.home,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
