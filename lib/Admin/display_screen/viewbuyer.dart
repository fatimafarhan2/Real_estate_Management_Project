import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/model/displaydetailSlidable.dart';
import 'package:real_estate_app/Admin/model/displaydetails.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewBuyer extends StatefulWidget {
  const ViewBuyer({super.key});

  @override
  State<ViewBuyer> createState() => _ViewBuyerState();
}

class _ViewBuyerState extends State<ViewBuyer> {
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
      final response = await client.from('client').select();
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
      emptyBodyText: "No Buyers Currently",
      appBarTitle: "Buyer's List",
      showAllItems: true,
      items: agents,
      fieldLabels: const [
        'Username',
        'First Name',
        'Last Name',
        'Email',
        'Phone Number'
      ],
      fieldKeys: const [
        'username',
        'firstname',
        'lastname',
        'email',
        'phonenumber'
      ],
      isLoading: isLoading,
      label: 'View Buyer',
      role: 'user',
    );
  }
}
