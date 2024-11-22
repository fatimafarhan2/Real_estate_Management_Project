import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:real_estate_app/Chat/pages/chatpage.dart';
import 'package:real_estate_app/Property/subpages/functions.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

double rating = 2.0;
String review = '';

class ViewAgent extends StatefulWidget {
  final String role;
  final String agentid;
  final firebaseagentid;
  ViewAgent(
      {super.key,
      required this.agentid,
      required this.role,
      required this.firebaseagentid});

  @override
  State<ViewAgent> createState() => _ViewAgentState();
}

class _ViewAgentState extends State<ViewAgent> {
  final SupabaseClient client = Supabase.instance.client;
  List<Map<String, dynamic>> properties = [];
  List<Map<String, dynamic>> agentinfo = [];
  double price = 0.0;
  String username = '';
  String phoneNumber = '';
  String email = '';
  String useridfirebase = '';
  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    fetchAgentProperties();
    fetchAgentInfo(); // Fetch properties on initialization
  }

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

  Future<void> fetchAgentInfo() async {
    try {
      final data =
          await client.from('agent').select().eq('agent_id', widget.agentid);

      if (data == null || data.isEmpty) {
        print('No agent information found.');
      } else {
        setState(() {
          print(data);
          agentinfo = List<Map<String, dynamic>>.from(data);
// Since agentinfo is a list, we need to access the first item using agentinfo[0] to retrieve the properties.

          // Access the first agent record
          // title = agentinfo[0]['title'] ?? 'No Title';
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
        ''').eq('agent_id', widget.agentid);

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

  Future<void> _addReview(BuildContext context) async {
    TextEditingController inputController = TextEditingController();
    TextEditingController ratingController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add your review for the agent'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: inputController,
                decoration: const InputDecoration(
                  hintText: 'Type something...',
                ),
              ),
              const SizedBox(height: 10.0),
              if (widget.role != 'admin') ...[
                TextField(
                  controller: ratingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Rate out of 5...',
                  ),
                  onChanged: (value) {
                    try {
                      double inputRating = double.parse(value);
                      if (inputRating >= 0 && inputRating <= 5) {
                        rating = inputRating;
                      } else {
                        rating = 0.0;
                      }
                    } catch (e) {
                      rating = 0.0;
                    }
                  },
                ),
                const SizedBox(height: 10.0),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 40.0,
                  allowHalfRating: true,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  onRatingUpdate: (newRating) {
                    setState(() {
                      rating = newRating;
                    });
                    ratingController.text = rating.toString();
                  },
                  itemBuilder: (context, index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                review = inputController.text;
                print('Rating: $rating');
                print('Review: $review');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Agent View', style: tappbar_style),
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            label: const Text('Hire This Agent'),
            icon: const Icon(Icons.person),
            style: ElevatedButton.styleFrom(
              iconColor: Colors.white,
              backgroundColor: drawerBoxColor,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6.0),
                        const Text('  Agent\n  Information ',
                            style: tUserTitle),
                        // Text('  Title: $title', style: tUserBody),
                        Text('  Username: $username', style: tUserBody),
                        Text('  Phone Number: $phoneNumber', style: tUserBody),
                        Text('  Email: $email', style: tUserBody),
                        Text('  Price: $price', style: tUserBody),
                        if (widget.role != 'admin') ...[
                          const Text('  Agent Rating:', style: tUserBody),
                          RatingBar(
                            initialRating: 4.0,
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
                        ]
                      ],
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
            const SizedBox(height: 10),
            const Text('Associated Properties',
                style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w700,
                    color: buttonColor)),
            const SizedBox(height: 10),
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
            const SizedBox(height: 50),
            if (widget.role != 'admin') ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                  sender: 'user',
                                  userId: useridfirebase,
                                  agentId: widget.firebaseagentid)),
                        );
                      },
                      label: Text('Chat'),
                      icon: Icon(Icons.message),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _addReview(context),
                      label: const Text('Review Agent',
                          style: TextStyle(color: Colors.white)),
                      icon: const Icon(Icons.rate_review),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          iconColor: Colors.white),
                    ),
                    Tooltip(
                      message: 'Report Agent',
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.report,
                            size: 45, color: buttonColor),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      label: const Text('View Agent Reviews',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          iconColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
