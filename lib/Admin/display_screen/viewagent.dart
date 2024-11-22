import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/model/displaydetailSlidable.dart';
import 'package:real_estate_app/Admin/model/displaydetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewAgents extends StatefulWidget {
  const ViewAgents({super.key});

  @override
  State<ViewAgents> createState() => _ViewAgentsState();
}

class _ViewAgentsState extends State<ViewAgents> {
  // made and instance of supabse
  final SupabaseClient client = Supabase.instance.client;

  //made a variable to store data retrieved
  List<Map<String, dynamic>> agents = [];
  bool isLoading = true;
  @override
  void printCurrentUser() {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      print("User ID: ${user.id}");
      print("Email: ${user.email}");
      print("User Metadata: ${user.userMetadata}");
    } else {
      print("No user is currently logged in.");
    }
  }

  void initState() {
    super.initState();
    printCurrentUser();
    fetchAgents();
  }

  Future<void> fetchAgents() async {
    try {
      print('Fetching agents...');
      //extracting Data
      final response = await client.from('agent').select();
      setState(() {
        agents = List<Map<String, dynamic>>.from(response);
        print('Data recieved');
        isLoading = false;
      });
    } catch (e) {
      print('eroor  occured');
      setState(() => isLoading = false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DisplayDetailsSlidable(
      emptyBodyText: "No Agents Currently",
      appBarTitle: "Agent's List",
      showAllItems: true,
      items: agents,
      fieldLabels: ['First Name', 'Last Name', 'Phone', 'Email', 'Price'],
      fieldKeys: ['f_name', 'l_name', 'phone', 'email', 'price'],
      isLoading: isLoading,
      label: 'View agent',
      role: 'agent',
    );
  }
}
