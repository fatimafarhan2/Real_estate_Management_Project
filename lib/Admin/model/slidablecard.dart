import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewAgent.dart';
import 'package:real_estate_app/Profiles/user_profile.dart';
import 'package:real_estate_app/Property/propertyView.dart';
import 'package:real_estate_app/UI/textstyle.dart';

class ListViewCardSlidable extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Slidable(
            key: ValueKey(index),
            endActionPane: ActionPane(motion: const ScrollMotion(), children: [
              SlidableAction(
                onPressed: (context) {
                  //will add db functiionality

                  if (role == 'user') {
                    String userId = item['client_id'];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfile(
                                  role: 'admin',
                                  userid: userId,
                                )));

                    // Add functionality for 'user' role
                  } else if (role == 'agent') {
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
                  } else if (role == 'property') {
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
                label: label,
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
                        children: List.generate(fieldKeys.length, (i) {
                          final fieldKey = fieldKeys[i];
                          final fieldLabel = fieldLabels[i];
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
