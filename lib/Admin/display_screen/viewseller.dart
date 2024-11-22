import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/model/displaydetailSlidable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewSellers extends StatefulWidget {
  const ViewSellers({super.key});

  @override
  State<ViewSellers> createState() => _ViewSellersState();
}

class _ViewSellersState extends State<ViewSellers> {
  final SupabaseClient client = Supabase.instance.client;

  // Variable to store data retrieved
  List<Map<String, dynamic>> agents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAgents();
  }

  // Fetching agent data (or any other client data) from the database
  Future<List<Map<String, dynamic>>> fetchClientsWithSellerMatch() async {
    try {
      final response = await client.rpc('get_clients_with_seller_match');
      //

      // Directly check if response is empty
      if (response.isEmpty) {
        print('No data returned from the database');
        return [];
      }

      print('Data fetched successfully: $response');
      return List<Map<String, dynamic>>.from(
          response); // Handle response directly
    } catch (e) {
      print('Unexpected error: $e');
      return [];
    }
  }

  // Method to fetch agents
  Future<void> fetchAgents() async {
    try {
      print('Fetching agents...');
      final data = await fetchClientsWithSellerMatch(); // Call the RPC function
      print("response data :$data");
      setState(() {
        agents = data; // Assign data from RPC response
        isLoading = false;
      });
    } catch (e) {
      print('Error occurred: $e');
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
      role: 'user',
      label: 'View Seller',
      emptyBodyText: "No Sellers Currently",
      appBarTitle: "Seller's List",
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
    );
  }
}
