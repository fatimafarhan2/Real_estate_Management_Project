import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:real_estate_app/Chat/pages/chatpage.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewAgentReviews.dart';
import 'package:real_estate_app/Property/subpages/functions.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/forms/Globalvariable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

double rating = 2.0;
String review = '';
//implement average rating function 
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

// Declare a global instance of Globalvariable

  Globalvariable hiredAgent = Globalvariable();
double avgRating =0;
  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    fetchAgentProperties();
    getAvgRating();
    fetchAgentInfo(); // Fetch properties on initialization
  }

Future<void> getAvgRating() async {
  try {
    // Perform the RPC call
    final response = await client.rpc('get_average_agent_rating', 
      params: {'id': widget.agentid},
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




  String getteragentid() {
    return widget.agentid;
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

Future<void> _addReport(BuildContext context) async {
  TextEditingController descriptionController = TextEditingController();
  String? selectedReportType;
  final reportTypes = ['Fraudulent', 'Harassment', 'Unresponsive']; // Dropdown options

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Property Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TextField for the description
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Report Description',
                hintText: 'Enter a detailed description...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3, // Allowing multiline input
            ),
            const SizedBox(height: 20), // Spacing
            // Dropdown for report type
            DropdownButtonFormField<String>(
              value: selectedReportType,
              items: reportTypes.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                selectedReportType = value!;
              },
              decoration: const InputDecoration(
                labelText: 'Report Type',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          // Save Button
          ElevatedButton.icon(
            onPressed: () {
              if (selectedReportType != null && descriptionController.text.isNotEmpty) {
                print('Description: ${descriptionController.text}');
                print('Report Type: $selectedReportType');
                
                String? userId = getCurrentUserIdAsString();
                  insertAgentReport(
                    reportType: selectedReportType!,
                     description: descriptionController.text,
                      clientId: userId!,
                       agentId: widget.agentid);
                // You can handle the saved input here
                Navigator.of(context).pop();
              } else {
                print('Please fill all fields'); // Handle validation
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      );
    },
  );



}


//INSERTION QUERIES
//to report agent

Future<void> insertAgentReport({
  required String reportType,
  required String description,
  required String clientId,
  required String agentId,
}) async {
  try {
    final response = await Supabase.instance.client
        .from('agent_reports') // Table name
        .insert({
          'report_type': reportType,          // Type of report (Fraudulent, Harassment, Unresponsive)
          'description': description,         // Detailed description of the report
          'client_id': clientId,              // Client ID (UUID)
          'agent_id': agentId,                // Agent ID (UUID)
          'date': DateTime.now().toIso8601String(), // Optional: Defaults to CURRENT_DATE in the table
        });

    if (response == null) {
      // Successful insertion
      print('Agent report inserted successfully!');
    } else {
      // Handle Supabase error
      print('Error:Unknown error occurred');
    }
  } catch (e) {
    // Handle unexpected errors
    print('Failed to insert agent report: $e');
  }
}



//for reviews
Future<void> insertAgentReview({
  required double rating,
  required String? comments,
  required String clientId,
  required String agentId,
}) async {
  try {
    final response = await Supabase.instance.client
        .from('agent_review') // Table name
        .insert({
          'rating': rating,             
          'comments': comments,         
          'client_id': clientId,         
          'agent_id': agentId,           
          'date': DateTime.now().toIso8601String(), // Optional: Defaults to CURRENT_DATE in the table
        });

    if (response == null ) {
      // Successful insertion
      print('Agent review inserted successfully!');
    } else {
      // Handle Supabase error
      print('Error:"Unknown error occurred"}');
    }
  } catch (e) {
    // Handle unexpected errors
    print('Failed to insert agent review: $e');
  }
}


String? getCurrentUserIdAsString() {
  final user = Supabase.instance.client.auth.currentUser;
  return user?.id; // Returns the user's UUID as a String or null if not logged in
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
              final userId = getCurrentUserIdAsString();
              setState(() {
                review = inputController.text;
                print('Rating: $rating');
                print('Review: $review');
                insertAgentReview(
                  rating: rating, 
                  comments: inputController.text, 
                  clientId: userId!, 
                  agentId: widget.agentid);
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
            //i will fetch the agent and store its id ,getter for fetching this particular agent id
            //this class object will return the id of agent to the property form page
            onPressed: () {
              hiredAgent.agent_id = widget.agentid;
              print(
                  'agent id : ${widget.agentid} Hired agent :${hiredAgent.agent_id}');
              Navigator.pop(context);
            },
            label: const Text('Hire This Agent'),
            icon: const Icon(Icons.person),
            style: ElevatedButton.styleFrom(
              iconColor:buttonColor,
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
                            // Text('  Title: $title', style: tUserBody),
                            Text('  Username: $username', style: tUserBody),
                            Text('  Phone Number: $phoneNumber', style: tUserBody),
                            Text('  Email: $email', style: tUserBody),
                            Text('  Hiring Fees: $price', style: tUserBody),
                            if (widget.role != 'admin') ...[
                              const Text('  Agent Rating:', style: tUserBody),
                             RatingBar.builder(
                                initialRating: avgRating,
                                minRating: 0,
                                direction: Axis.horizontal,
                                itemCount: 5,
                                itemSize: 30,
                                allowHalfRating: true,
                                ignoreGestures: true,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                onRatingUpdate: (newRating) {
                                 
                                },
                                itemBuilder: (context, index) => Icon(
                                  index < avgRating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                ),
                              ),

                            ]
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: const Text('Properties',
                        style: TextStyle(                
                            fontSize: 33,
                            fontWeight: FontWeight.w700,
                            color: buttonColor)),
                  ), 
                      const SizedBox(width: 50.0,),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        iconColor: Colors.white),
                      label: const Text('Chat with Agent',style: tbutton_style,),
                      icon: const Icon(Icons.message),
                    ),
                ],
              ),
            ),
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
                        onPressed: () => _addReport(context),
                        icon: const Icon(Icons.report,
                            size: 45, color: buttonColor),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                          Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  ViewAgentReviews( agentid: widget.agentid,)
                            // for refresh
                            ),
                      );
                      },
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
