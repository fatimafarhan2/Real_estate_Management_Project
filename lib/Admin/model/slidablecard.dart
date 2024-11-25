import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewAgent.dart';
import 'package:real_estate_app/Profiles/user_profile.dart';
import 'package:real_estate_app/Property/propertyView.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/login_and_signup/Firebase/Authserviceuser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListViewCardSlidable extends StatefulWidget {
  const ListViewCardSlidable(
      {super.key,
      required this.filteredItems,
      required this.fieldLabels,
      required this.fieldKeys,
      required this.label,
      required this.role,
      required this.items});

  final String label;
  final String role;
  final List<Map<String, dynamic>> filteredItems;
  final List<String> fieldLabels; // Field labels to show in the UI
  final List<String> fieldKeys; // Keys corresponding to field data in each item
  final List<Map<String, dynamic>> items;

  @override
  State<ListViewCardSlidable> createState() => _ListViewCardSlidableState();
}

class _ListViewCardSlidableState extends State<ListViewCardSlidable> {
  final AuthServicesUser _auth = AuthServicesUser();

// ------------------DELETON FUNCTIONS-------------------------------
  Future<void> deleteAgent(String agentId, String email) async {
    final response =
        await Supabase.instance.client.rpc('delete_agent', params: {
      'user_id': agentId,
    });

    if (response != null) {
      print('Error deleting agent: ${response.error!.message}');
    } else {
      _auth.deleteAgentByEmail(email);
      print('Agent deleted successfully');
    }
  }

  Future<void> deleteUser(String userId, String email) async {
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
      print('Property and relationship deleted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.filteredItems.length,
      itemBuilder: (context, index) {
        final item = widget.filteredItems[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Slidable(
            key: ValueKey(index),
            endActionPane: ActionPane(motion: const ScrollMotion(), children: [
              SlidableAction(
                onPressed: (context) {
                  //will add db functiionality

                  if (widget.role == 'user') {
                    String userId = item['client_id'];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfile(
                                  role: 'admin',
                                  userid: userId,
                                )));

                    // Add functionality for 'user' role
                  } else if (widget.role == 'agent') {
                    String agentId = item['agent_id'];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewAgent(
                                  role: 'admin',
                                  agentid: agentId,
                                  firebaseagentid: '',
                                )));
                    // Add functionality for 'agent' role
                  } else if (widget.role == 'property') {
                    int property_id = item['property_id'];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Propertyview(
                                  propertyid: property_id,
                                  role: 'admin',
                                )));

                    // Add functionality for 'property' role
                  }
                },
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                icon: Icons.view_carousel,
                label: widget.label,
              )
            ]),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Item details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(widget.fieldKeys.length, (i) {
                          final fieldKey = widget.fieldKeys[i];
                          final fieldLabel = widget.fieldLabels[i];
                          return Text(
                            '$fieldLabel: ${item[fieldKey] ?? 'N/A'}',
                            style: tUserBody,
                          );
                        }),
                      ),
                    ),
                    // Action buttons

                    Tooltip(
                      message: 'Remove',
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.role == 'agent') {
                            String id = item['agent_id'];
                            String email = item['email'];
                            deleteAgent(id, email);
                          } else if (widget.role == 'user') {
                            String email = item['email'];
                            String id = item['client_id'];
                            deleteUser(id, email);
                          } else if (widget.role == 'property') {
                            int id = item['property_id'];
                            deletePropertyAndRelationship(id);
                          }
                          // Reject action
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(14),
                          backgroundColor: Colors.red,
                        ),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
