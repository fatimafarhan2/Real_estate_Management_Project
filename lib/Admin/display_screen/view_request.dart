import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/model/displaydetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewRequest extends StatefulWidget {
  const ViewRequest({super.key});

  @override
  State<ViewRequest> createState() => _ViewRequestState();
}

class _ViewRequestState extends State<ViewRequest> {
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
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      print('Fetching agents...');
      //extracting Data
      final response = await client.from('requests').select();
      setState(() {
        agents = List<Map<String, dynamic>>.from(response);
        print(agents);
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
      emptyBodyText: "No Requests Currently",
      appBarTitle: "Requests",
      showAllItems: true,
      items: agents,
      fieldLabels: const ['Request', 'Date', 'Status', 'User', 'Property'],
      fieldKeys: const [
        'request_id',
        'date',
        'status',
        'client_id',
        'property_id',
      ],
      isLoading: isLoading,
      action: 'request',
    );
  }
}
