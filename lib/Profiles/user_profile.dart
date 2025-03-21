import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/display_screen/viewagent.dart';
import 'package:real_estate_app/Chat/pages/agentlist.dart';
import 'package:real_estate_app/Chat/pages/chatLogpage.dart';
import 'package:real_estate_app/Homepage/homepage.dart';
import 'package:real_estate_app/Profiles/sub_pages/userProfileUpdatedPage.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewAgent.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewWishlists.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/forms/property_details_form.dart';
import 'package:real_estate_app/login_and_signup/Firebase/Authserviceuser.dart';
import 'package:real_estate_app/login_and_signup/authServices.dart';
import 'package:real_estate_app/login_and_signup/login_signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Navigators done

class UserProfile extends StatefulWidget {
  final String role;
  final String userid;
  const UserProfile({
    super.key,
    required this.userid,
    required this.role,
  });
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String username = '';
  String phoneNumber = '';
  String email = '';
  String profilePic = '';
  final SupabaseClient client = Supabase.instance.client;

  List<Map<String, dynamic>> properties = [];

  List<Map<String, dynamic>> agentinfo = [];

  List<Map<String, dynamic>> userinfo = [];

  final ScrollController _scrollController = ScrollController();
  bool _showBottomBar = false;

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

  List<Map<String, dynamic>> appointments = [];
  Future<void> fetchAppointments() async {
    try {
      print('client id:$clientSupabaseId');

      final data = await client
          .from('appointments')
          .select('date, agent_id, meet_address,agent(username)')
          .eq('buyer_id', clientSupabaseId);

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

//----------------------------------------deletion transaction

  final AuthServicesUser _auth = AuthServicesUser();

  Future<void> deleteUser(String userId, String email) async {
    // final curruser =client
    final response = await Supabase.instance.client.rpc('delete_user', params: {
      'user_id': userId,
    });

    if (response != null) {
      print('Error deleting user: ${response.error!.message}');
    } else {
      _auth.deleteUserByEmail(email);
      print('User deleted successfully');
    }
  }

  Future<void> deletePropertyAndRelationship(int propertyId) async {
    final response = await Supabase.instance.client
        .rpc('delete_property_and_relationship', params: {
      'p_property_id': propertyId,
    });

    if (response != null) {
      print(
          'Error deleting property and relationship: ${response.error!.message}');
    } else {
      //snackabr
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property deleted successfully!')),
      );
      print('Property and relationship deleted successfully');
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

  String clientSupabaseId = '';
  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    print("profile picture url: ${profilePic}");
    fetchUserProperties();
    fetchAgentInfo();
    getCurrentUserId();
    getCurrentUser();
    // Listen to scroll events
    fetchAppointments();
    _scrollController.addListener(_scrollListener); // changes
    // Fetch properties on initialization
  }

//error: org-dartlang-debug:synthetic_debug_expression:1:1: Error: The getter 'data' isn't defined for the class '_UserProfileState'.
//  - '_UserProfileState' is from 'package:real_estate_app/Profiles/user_profile.dart' ('lib/Profiles/user_profile.dart').
// Try correcting the name to the name of an existing getter, or defining a getter or field named 'data'.
// data
// ^^^^
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge) {
      final isBottom = _scrollController.position.pixels > 0;
      setState(() {
        _showBottomBar =
            isBottom; // _showBottomBar is set to true if at the bottom edge
      });
    } else {
      setState(() {
        _showBottomBar = false; // Otherwise, it is set to false
      });
    }
  }

  Future<void> getCurrentUser() async {
    try {
      // Get the current user from Supabase
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        clientSupabaseId = user.id;
        print("Current User ID: ${user.id}");
      } else {
        print("No user is currently logged in.");
      }
    } catch (e) {
      print("Error fetching current user: $e");
      return null;
    }
  }

  int prop_id = 0;
//pop for deleting account
  Future<void> _deleteAccount(
      BuildContext context, bool entity, int prop_id) async {
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

              deleteUser(widget.userid, email);
              Navigator.of(context).pop(); // Close the dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginSignUp()
                    // for refresh
                    ),
              );

              // Close the dialog
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

  Future<void> _deleteProperties(
      BuildContext context, bool entity, int prop_id) async {
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
              print(prop_id);
              deletePropertyAndRelationship(prop_id);
              fetchUserProperties();
              //if bool is yes add query for property else for
              //for deletion of account
              Navigator.of(context).pop(); // Close the dialog
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

//fetching all agents hired by user

// ----------------------------------///change joined table-> agent extract.
  Future<void> fetchAgentInfo() async {
    try {
      final data = await client.rpc('get_agent_for_client', params: {
        'p_client_id': widget.userid, // Pass client ID as a parameter
      });

      if (data == null || data.isEmpty) {
        print('No properties found for this agent.');
      } else {
        setState(() {
          print(data);
          agentinfo = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetching agent properties: $e');
    }
  }

//frtching all user info
  Future<void> fetchUserInfo() async {
    try {
      final data =
          await client.from('client').select().eq('client_id', widget.userid);

      if (data == null || data.isEmpty) {
        print('No client information found.');
      } else {
        setState(() {
          print(data);
          userinfo = List<Map<String, dynamic>>.from(data);
// Since agentinfo is a list, we need to access the first item using agentinfo[0] to retrieve the properties.

          // Access the first agent record
          // title = agentinfo[0]['title'] ?? 'No Title';
          username = userinfo[0]['username'] ?? 'No Username';
          phoneNumber = userinfo[0]['phonenumber'] ?? 'No Phone Number';
          email = userinfo[0]['email'] ?? 'No Email';
          profilePic = userinfo[0]['profile_picture'] ?? 'No profile picture';
        });
      }
    } catch (e) {
      print('Error fetching client information: $e');
    }
  }

//fetching the properties associated with users
  Future<void> fetchUserProperties() async {
    try {
      final data = await client.from('properties').select('''
          property_id,
          title,
          price,
          status,
          category:property_category (
            category_name
          )
        ''').eq('seller_id', widget.userid);

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
        title: const Text(
          'User Profile',
          style: tappbar_style,
        ),
        actions: [
          if (widget.role != 'admin')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewWishlist(
                              userid: widget.userid,
                            )));
              },
              label: const Text(
                'View WishList',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.star),
              style: ElevatedButton.styleFrom(
                backgroundColor: drawerBoxColorTwo,
                foregroundColor: buttonColor,
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            // Display User Info and Agent Info
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipOval(
                      child: Image.asset('images/pp1.jpg',
                          height: 160, width: 160),
                    ),
                  ),
                  // User Information Section
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 400,
                      height: 200,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.2), // Shadow color
                            blurRadius: 15, // Softness of the shadow
                            spreadRadius: 0.8, // Extend the shadow
                            offset:
                                const Offset(10, 10), // Position of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15.0),
                        color: drawerBoxColorTwo,
                      ),
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        double maxwidth = constraints.maxWidth;
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: maxwidth > 600
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 6.0),
                                          const Text(
                                            'User Information',
                                            style: tUserTitle,
                                          ),
                                          Text(
                                            'User Name: $username',
                                            style: tUserBody,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      // Start Expanded (Right Column)
                                      child: Column(
                                        // Start Right Column
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Phone Number: $phoneNumber',
                                              style: tUserBody),
                                          Text('Email: $email',
                                              style: tUserBody),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const UserProfileUpdatePage()
                                                    // for refresh
                                                    ),
                                              );
                                            },
                                            label: const Text(
                                              'Update Profile',
                                              style: tbutton_style,
                                            ),
                                            icon: const Icon(Icons.update),
                                            style: ElevatedButton.styleFrom(
                                              iconColor: Colors.white,
                                              backgroundColor: buttonColor,
                                            ),
                                          )
                                        ],
                                      ), // End Right Column
                                    ),
                                  ],
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Column(
                                      // Start Column for narrow layout
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'User Information',
                                          style: tUserTitle,
                                        ),
                                        Text('User Name: $username',
                                            style: tUserBody),
                                        Text('Phone Number: $phoneNumber',
                                            style: tUserBody),
                                        Text('Email: $email', style: tUserBody),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const UserProfileUpdatePage()
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
                                  ),
                                ),
                        );
                      }),
                    ),
                  ),
                  // User Profile Picture Section
                ],
              ),
            ),

            // Display Agent Information
            Container(
              padding: const EdgeInsets.all(10.0), // Add vertical padding
              alignment: Alignment.topLeft, // Center the text
              child: const Text(
                'Agents Hired',
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    blurRadius: 15, // Softness of the shadow
                    spreadRadius: 0.8, // Extend the shadow
                    offset: const Offset(10, 10), // Position of the shadow
                  ),
                ],
                color: drawerBoxColorTwo,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (agentinfo
                          .isNotEmpty) // Check if agent data is available
                        for (var agent
                            in agentinfo) // Loop through the agent data
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 10,
                              height: 110, // Increased height to fit all info
                              child: ElevatedButton.icon(
                                onPressed:
                                    () {}, //to go to that agent's View page
                                label: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      agent['username'] ??
                                          'No Name', // Display agent's name
                                      style: tAppointmentButton,
                                      textAlign: TextAlign.start,
                                    ),
                                    Text(
                                      'Phone: ${agent['phone_number'] ?? 'No Phone'}', // Display agent's phone number
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                    Text(
                                      'Email: ${agent['email'] ?? 'No Email'}', // Display agent's email
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ],
                                ),
                                icon: const Icon(Icons.person_2),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  iconColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                      horizontal: 20.0), // Padding
                                ),
                              ),
                            ),
                          )
                      else
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No agents hired.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            //displaying Appointment
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: appointments.map((appointment) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: buttonColor,
                          margin: const EdgeInsets.all(2.0),
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Seller: ${appointment['agent']?['username']}  \nDate: ${appointment['date']}  \nLocation: ${appointment['meet_address']}',
                              style: tDrawerButton,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Display properties with ListView.builder

            // -----------------------------------------------------------Changed and added button-----------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0), // Add vertical padding
                  alignment: Alignment.topLeft, // Center the text
                  child: const Text(
                    'Properties',
                    style: TextStyle(
                      fontSize: 33,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                      color: buttonColor,
                    ),
                  ),
                ),
                // SizedBox(
                //   width: 90,
                // ),
                Container(
                  decoration: const BoxDecoration(
                    color: buttonColor, // Background color
                    shape: BoxShape.circle, // Makes the background circular
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PropertyDetails()
                            // for refresh
                            ),
                      );
                    },
                    icon: Icon(Icons.add),
                    color: scaffoldColor,
                  ),
                )
              ],
            ),
            // -----------------------------------------------------------Changed and added button-----------------------------------
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Property: ${properties[index]['title']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18.0,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Status: ${properties[index]['status']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18.0,
                                      color: Colors.white),
                                ),
                                Text(
                                  'Price: \$${properties[index]['price']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18.0,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                int prop_id = properties[index]['property_id'];
                                print('property id :$prop_id');
                                _deleteProperties(context, true, prop_id);
                              },
                              icon: const Icon(Icons.delete),
                              color: Colors.white,
                            )
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
            if (widget.role != 'admin')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AgentListPage()),
                      );
                    },
                    icon: const Icon(Icons.person),
                    label: const Text(
                      'View Agents',
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                        );
                      }, //homepage
                      color: Colors.white, // Icon color
                      icon: const Icon(Icons.house_outlined),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserChatLogPage(userId: useridfirebase)),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text(
                      'View Chat',
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
            const SizedBox(height: 15),
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
                    onPressed: () => _deleteAccount(context, false, 0),
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
