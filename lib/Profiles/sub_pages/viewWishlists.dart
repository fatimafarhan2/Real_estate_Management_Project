import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// implement if else bool variable to check when to select all agents or when to select agents associated with a specific user
class ViewWishlist extends StatefulWidget {
  final String userid;
  ViewWishlist({super.key, required this.userid});

  @override
  State<ViewWishlist> createState() => _ViewWishlistState();
}

class _ViewWishlistState extends State<ViewWishlist> {
  final SupabaseClient client = Supabase.instance.client;

  List<Map<String, dynamic>> wishlistinfo = []; // Change to List of Maps

  Future<void> fetchwishlist() async {
    try {
      final data =
          await client.rpc('get_wishlist_info', params: {'cid': widget.userid});

      print(data);

      if (data == null || data.isEmpty) {
        print('No wishlist found.');
      } else {
        setState(() {
          // Since we expect multiple rows of data, we directly assign it to wishlistinfo
          wishlistinfo = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetching wishlist information: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchwishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Wishlist',
            style: tappbar_style,
          ),
        ),
        backgroundColor: buttonColor,
      ),
      backgroundColor: propertyBGColor,
      body: wishlistinfo.isEmpty
          ? const Center(child: Text('Empty Wishlist'))
          : ListView.builder(
              itemCount: wishlistinfo.length, // Use length of the list
              itemBuilder: (context, index) {
                final offer =
                    wishlistinfo[index]; // Get the individual map (row)
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Slidable(
                      key: ValueKey(index),
                      endActionPane:
                          ActionPane(motion: const ScrollMotion(), children: [
                        SlidableAction(
                          onPressed: (context) {
                            // will add db functionality
                          },
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          icon: Icons.view_carousel,
                          label: 'View Property',
                        )
                      ]),
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            'Property Name: ${offer['property_name'] ?? ''}', // Access values from the individual map
                            style: tAppointmentBody,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buyer Name: ${offer['client_name'] ?? 'Anonymous'}',
                                style: tUserBody,
                              ),
                              Text(
                                'Agent Name: ${offer['agent_name'] ?? ''}',
                                style: tUserBody,
                              ),
                              Text(
                                'Date: ${offer['date_added'] ?? 'N/A'}',
                                style: tUserBody,
                              ),
                            ],
                          ),
                          leading: const Icon(
                            Icons.dashboard_customize,
                            color: Colors.green,
                          ),
                        ),
                      )),
                );
              },
            ),
    );
  }
}
