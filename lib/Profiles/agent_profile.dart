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
import 'package:real_estate_app/login_and_signup/login_signup.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _showBottomBar = false;
  double avgRating = 0.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getCurrentUserId() async {
    var user1 = FirebaseAuth.instance.currentUser; // Get the current user

    if (user1 != null) {
      setState(() {
        useridfirebase = user1.uid;
        print('agentidfirebase:$useridfirebase');
      });
    } else {
      setState(() {
        useridfirebase = '';
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.maxScrollExtent ==
        _scrollController.position.pixels) {
      // User is at the bottom of the scrollable content
      setState(() {
        _showBottomBar = true;
      });
    } else {
      setState(() {
        _showBottomBar = false;
      });
    }
  }

  int prop_id = 0;
//pop for deleting account
  Future<void> _deleteAccount(
      BuildContext context, String email, String agentid) async {
    //bool entity true of to be deleted is a property else false if an acocount
    TextEditingController inputController = TextEditingController();
    TextEditingController ratingController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you wish to delete ?'),
        content: const SizedBox(height: 10.0),
        actions: [
          TextButton(
            onPressed: () {
              // Action for 'Yes' button
              //add query here

              deleteAgent(agentid, email);
              //if bool is yes add query for property else for
              //for deletion of account
              Navigator.of(context).pop(); // Close the dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginSignUp()
                    // for refresh
                    ),
              );
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              // Action for 'No' button
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  final AuthServicesUser _auth = AuthServicesUser();
  Future<void> deleteAgent(String agent_id, String email) async {
    final response =
        await Supabase.instance.client.rpc('delete_agent', params: {
      'user_id': agent_id,
    });

    if (response != null) {
      print('Error deleting agent: ${response.error!.message}');
    } else {
      _auth.deleteAgentByEmail(email);
      print('Agent deleted successfully');
    }
  }

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

  Future<void> getAvgRating() async {
    try {
      // Perform the RPC call
      final response = await client.rpc(
        'get_average_agent_rating',
        params: {'id': agentid},
      );
      print(response);

      if (response != null) {
        setState(() {
          avgRating = response as double? ?? 0.0;
        });
        print("Avg rating: $avgRating");
      } else {
        setState(() {
          avgRating = 0.0;
        });
        print("No rating data found");
      }
    } catch (e) {
      print("Unexpected error: $e");
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
          .select('date, buyer_id, meet_address,client(username)')
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
    fetchAppointments();
    getCurrentUserId(); // Fetch appointments data
    getAvgRating();

    _scrollController.addListener(_scrollListener); // changes
  }

  bool _isHovering = true;
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AgentProfileUpdatePage()
                    // for refresh
                    ),
              );
            },
            label: const Text(
              'Update Profile',
              style: tbutton_style,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController, // Attach the ScrollController
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
                              initialRating: avgRating,
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
              padding: const EdgeInsets.all(6.0),
              height: 200,
              width: 390,
              decoration: BoxDecoration(
                color: drawerBoxColorTwo,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    blurRadius: 15, // Softness of the shadow
                    spreadRadius: 0.8, // Extend the shadow
                    offset: const Offset(10, 10), // Position of the shadow
                  ),
                ],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: appointments.map((appointment) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          color: buttonColor,
                          margin: const EdgeInsets.all(2.0),
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Date: ${appointment['date']} \nBuyer: ${appointment['username']} \nLocation: ${appointment['meet_address']}',
                              style: tAppointmentButton,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
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
            const SizedBox(
              height: 53,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const SizedBox(
                      width: 50,
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
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.home,
                          size: 40,
                          color: scaffoldColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewOffers(
                                    agentid: agentid,
                                  )),
                        );
                      },
                      icon: const Icon(Icons.person),
                      label: const Text(
                        'Offers',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _showBottomBar
          ? BottomAppBar(
              color: const Color.fromARGB(255, 63, 13, 9),
              height: 60,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => _deleteAccount(context, email, agentid),
                    child: const Text(
                      'DELETE ACCOUNT',
                      style: tappbar_style,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
