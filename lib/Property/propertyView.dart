import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/Property/subpages/functions.dart';
import 'package:real_estate_app/Property/subpages/viewComments.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String userComment = '';

//function to take comment as input
class Propertyview extends StatefulWidget {
  final String role;
  final int propertyid;

  const Propertyview({
    super.key,
    required this.propertyid,
    required this.role,
  });

  @override
  State<Propertyview> createState() => _PropertyviewState();
}

class _PropertyviewState extends State<Propertyview> {
  final SupabaseClient client = Supabase.instance.client;
  List<Map<String, dynamic>> properties = [];
  List<Map<String, dynamic>> userinfo = [];

  Map<String, dynamic> agentinfo = {};

  // Property details variables

  double price = 0.0;
  String location = '';
  double sizeofprop = 0.0;
  int noofroom = 0;
  int noofbroom = 0;
  String status = '';
  String titl = '\0';
  String city = '';
  String sellerid = '';
  // Seller information variables
  String sellerUsername = '';
  String sellerPhoneNumber = '';
  String sellerEmail = '';

// Fetching property details
  Future<void> fetchPropertiesInfo() async {
    try {
      final data = await client.from('properties').select('''
        *,
        category:property_category(category_name)
      ''').eq('property_id', widget.propertyid);

      print(data);
      if (data == null || data.isEmpty) {
        print('No property found.');
      } else {
        setState(() {
          properties = List<Map<String, dynamic>>.from(data);

          // Assuming the first property (index 0) contains the needed data
          final propertyData = properties[0];

          // Access and store property-related information
          // propertyId = propertyData['property_id'] ?? '';
          price = propertyData['price'] ?? 0.0;
          location = propertyData['address'] ?? '';
          sizeofprop = propertyData['area'] ?? 0.0;
          noofroom = propertyData['num_of_room'] ?? 0;
          noofbroom = propertyData['num_of_bathroom'] ?? 0;
          status = propertyData['status'] ?? '';
          titl = propertyData['title'] ?? '';
          city = propertyData['city'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching property information: $e');
    }
  }

  Future<void> fetchUserInfo() async {
    try {
      final data = await client
          .rpc('get_seller_info', params: {'pid': widget.propertyid});

      print(data);
      if (data == null || data.isEmpty) {
        print('No user info found.');
      } else {
        setState(() {
          userinfo = List<Map<String, dynamic>>.from(data);

          // Assuming the first user (index 0) contains the seller data
          final userData = userinfo[0];

          // Access and store seller information
          sellerUsername = userData['username'] ?? '';
          sellerPhoneNumber = userData['phonenumber'] ?? '';
          sellerEmail = userData['email'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user information: $e');
    }
  }

  // to fetch agent info who is associated with the property
  Future<void> fetchAgentInfo() async {
    try {
      final data = await client
          .rpc('get_agentprop_info', params: {'pid': widget.propertyid});

      print(data);
      if (data == null || data.isEmpty) {
        print('No agent info found.');
      } else {
        setState(() {
          agentinfo = Map<String, dynamic>.from(
              data[0]); // Convert the first result to a Map
        });
      }
    } catch (e) {
      print('Error fetching agent information: $e');
    }
  }

  Future<void> _addComment(BuildContext context) async {
    TextEditingController inputController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add your comment'),
        content: TextField(
          controller: inputController,
          decoration: const InputDecoration(
            hintText: 'Type something...',
            fillColor: Colors.red,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                userComment = inputController.text;
                print(userComment);
              });
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchPropertiesInfo(); // Fetch property info
    fetchUserInfo(); // Fetch user info (seller)
    fetchAgentInfo();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Sage Appartments',
          style: tappbar_style,
        ),
      ),
      backgroundColor: propertyBGColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Adjusting the space here
              const SizedBox(height: 10), // Reduce this height as needed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    label: const Text(
                      'Report',
                      style:
                          TextStyle(color: Color.fromARGB(255, 252, 229, 229)),
                    ),
                    icon: const Icon(Icons.report),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 110, 34, 2),
                      iconColor: const Color.fromARGB(255, 252, 229, 229),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    label: const Text(
                      'Wishlist+',
                      style:
                          TextStyle(color: Color.fromARGB(255, 250, 249, 246)),
                    ),
                    icon: const Icon(Icons.star),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(185, 210, 141, 29),
                      iconColor: const Color.fromRGBO(248, 184, 10, 1),
                    ),
                  ),
                ],
              ),
              // Add a SizedBox with reduced height
              const SizedBox(height: 15), // Reduce this height as needed
              ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.asset(
                  'images/property1.jpeg',
                  height: 250,
                  width: 390,
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {},
                        label: const Text(
                          'Chat',
                          style: TextStyle(
                              color: Color.fromARGB(255, 202, 220, 242)),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 5, 19, 77),
                            iconColor:
                                const Color.fromARGB(255, 202, 220, 242))),
                    ElevatedButton.icon(
                        onPressed: () async {
                          String phoneNumber =
                              '+923323973587'; //await fetchPhoneNumberFromDatabase();
                          if (phoneNumber.isNotEmpty) {
                            await callAgent(agentinfo['phone_number']);
                          }
                        },
                        label: const Text(
                          'Call Agent',
                          style: TextStyle(
                              color: Color.fromARGB(255, 218, 199, 240)),
                        ),
                        icon: const Icon(Icons.call_end_rounded),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 40, 9, 69),
                            iconColor:
                                const Color.fromARGB(255, 218, 199, 240))),
                    ElevatedButton.icon(
                        onPressed: () => showEmail(context, agentinfo['email']),
                        label: const Text(
                          'Email',
                          style: TextStyle(
                              color: Color.fromARGB(255, 222, 173, 221)),
                        ),
                        icon: const Icon(Icons.email_outlined),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 73, 4, 76),
                            iconColor:
                                const Color.fromARGB(255, 222, 173, 221))),
                  ],
                ),
              ),

              propertyHeading(
                const Text(
                  'Property Information',
                  style: TextStyle(
                    fontSize: 33,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    color: buttonColor,
                  ),
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: propertyBox(SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                          width: 10,
                        ),
                        Text('Property Name: $titl', style: tProperty_info),
                        SizedBox(
                          height: 10,
                          width: 10,
                        ),
                        Text('Location: $location', style: tProperty_info),
                        SizedBox(
                          height: 10,
                          width: 10,
                        ),
                        Text('Price: \$${price.toString()}',
                            style: tProperty_info),
                        SizedBox(
                          height: 10,
                          width: 10,
                        ),
                        Text('City: $city', style: tProperty_info),
                        SizedBox(
                          height: 10,
                          width: 10,
                        ),
                        Text('Rooms: $noofroom', style: tProperty_info),
                        SizedBox(
                          height: 10,
                          width: 10,
                        ),
                        Text('Bathrooms: $noofbroom', style: tProperty_info),
                        SizedBox(
                          height: 10,
                          width: 10,
                        ),
                      ],
                    ),
                  )),
                ),
              ),
              const SizedBox(
                width: 20,
                height: 30,
              ),

              propertyHeading(
                const Text(
                  'Price Information',
                  style: TextStyle(
                    fontSize: 33,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    color: buttonColor,
                  ),
                ),
              ),

              propertyBox(SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                        width: 10,
                      ),
                      Text("Agent: ${agentinfo['username'] ?? 'N/A'}",
                          style: tProperty_info),
                      SizedBox(
                        height: 10,
                        width: 10,
                      ),
                      Text("Agent: ${agentinfo['email'] ?? 'N/A'}",
                          style: tProperty_info),
                      SizedBox(
                        height: 10,
                        width: 10,
                      ),
                      Text("Agent: ${agentinfo['phone_number'] ?? 'N/A'}",
                          style: tProperty_info),
                      SizedBox(
                        height: 10,
                        width: 10,
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(
                width: 20,
                height: 30,
              ),

              propertyHeading(
                const Text(
                  'Seller Information',
                  style: TextStyle(
                    fontSize: 33,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    color: buttonColor,
                  ),
                ),
              ),

              propertyBox(SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seller Name: $sellerUsername',
                          style: tProperty_info),
                      SizedBox(
                        height: 10,
                        width: 10,
                      ),
                      Text('Phone Number: $sellerPhoneNumber',
                          style: tProperty_info),
                      SizedBox(
                        height: 10,
                        width: 10,
                      ),
                      Text('Email: $sellerEmail', style: tProperty_info),
                    ],
                  ),
                ),
              )),
              const SizedBox(
                width: 20,
                height: 30,
              ),

              if (widget.role != 'admin')
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _addComment(context),
                      label: const Text(
                        'Add a Comment',
                        style: TextStyle(
                            color: Color.fromARGB(255, 203, 208, 189)),
                      ),
                      icon: const Icon(Icons.comment),
                      style: ElevatedButton.styleFrom(
                        iconColor: const Color.fromARGB(255, 203, 208, 189),
                        backgroundColor: const Color.fromARGB(255, 2, 41, 19),
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Viewcomments()),
                        );
                      },
                      label: const Text('View Comments',
                          style: TextStyle(
                              color: Color.fromARGB(255, 203, 208, 189))),
                      icon: const Icon(Icons.comment_bank_outlined),
                      style: ElevatedButton.styleFrom(
                        iconColor: const Color.fromARGB(255, 203, 208, 189),
                        backgroundColor: const Color.fromARGB(255, 2, 41, 19),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
