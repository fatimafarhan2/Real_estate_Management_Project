import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/model/displaydetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewAgentReports extends StatefulWidget {
  const ViewAgentReports({super.key});

  @override
  State<ViewAgentReports> createState() => _ViewAgentReportsState();
}

class _ViewAgentReportsState extends State<ViewAgentReports> {
  // made and instance of supabse
  final SupabaseClient client = Supabase.instance.client;

  //made a variable to store data retrieved
  List<Map<String, dynamic>> agents = [];
  bool isLoading = true;
  @override
  // void printCurrentUser() {
  //   final user = Supabase.instance.client.auth.currentUser;

  //   if (user != null) {
  //     print("User ID: ${user.id}");
  //     print("Email: ${user.email}");
  //     print("User Metadata: ${user.userMetadata}");
  //   } else {
  //     print("No user is currently logged in.");
  //   }
  // }

  void initState() {
    super.initState();
    // printCurrentUser();
    fetchAgents();
  }

  Future<void> fetchAgents() async {
    try {
      print('Fetching agents...');
      //extracting Data
      final response = await client.from('agent_reports').select();
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
    return DisplayDetails(
      emptyBodyText: "No Agent Report's Currently",
      appBarTitle: "Reports",
      showAllItems: true,
      items: agents,
      fieldLabels: const [
        'Report',
        'Date',
        'Reported by',
        'Reported',
        'Description',
      ],
      fieldKeys: const [
        'report_type',
        'date',
        'client_id',
        'agent_id',
        'description'
      ],
      isLoading: isLoading,
    );
  }
}
