import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListViewCard extends StatelessWidget {
  const ListViewCard(
      {super.key,
      required this.filteredItems,
      required this.fieldLabels,
      required this.fieldKeys,
      required this.action});
  final String action;
  final List<Map<String, dynamic>> filteredItems;
  final List<String> fieldLabels; // Field labels to show in the UI
  final List<String> fieldKeys; // Keys corresponding to field data in each item

  Future<void> update_request(int id, String status) async {
    final SupabaseClient client = Supabase.instance.client;

    try {
      // Update the status of the request where the request_id matches the provided id
      final response = await client
          .from('requests')
          .update({'status': status}).eq('request_id', id);

      // Check if any rows were updated
      if (response.count == null || response.count == 0) {
        print(
            "No rows updated. Either the request_id was not found, or another issue occurred.");
      } else {
        print("Update successful for request_id: $id");
      }
    } catch (e) {
      // Handle any exceptions during the update
      print("An error occurred: $e");
    }
  }

  Future<void> update_propertyreport(int id, String status) async {
    final SupabaseClient client = Supabase.instance.client;

    try {
      // Update the status of the request where the request_id matches the provided id
      final response = await client
          .from('property_reports')
          .update({'status': status}).eq('p_report_id', id);

      // Check if any rows were updated
      if (response.count == null || response.count == 0) {
        print(
            "No rows updated. Either the property report was not found, or another issue occurred.");
      } else {
        print("Update successful for property report: $id");
      }
    } catch (e) {
      // Handle any exceptions during the update
      print("An error occurred: $e");
    }
  }

  Future<void> update_agentreport(int id, String status) async {
    final SupabaseClient client = Supabase.instance.client;

    try {
      // Update the status of the request where the request_id matches the provided id
      final response = await client
          .from('agent_reports')
          .update({'status': status}).eq('a_report_id', id);

      // Check if any rows were updated
      if (response.count == null || response.count == 0) {
        print(
            "No rows updated. Either the property report was not found, or another issue occurred.");
      } else {
        print("Update successful for property report: $id");
      }
    } catch (e) {
      // Handle any exceptions during the update
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
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

                  Column(
                    children: [
                      Tooltip(
                        message: 'Approve',
                        child: ElevatedButton(
                          onPressed: () {
                            if (action == 'request') {
                              int id = item['request_id'];
                              print(id);
                              update_request(id, 'Approved');
                            } else if (action == 'propertyreport') {
                              int id = item['p_report_id'];
                              update_request(id, 'approved');
                            } else if (action == 'agentreport') {
                              int id = item['a_report_id'];
                              update_propertyreport(id, 'Approve');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(14),
                            backgroundColor: Colors.green,
                          ),
                          child: Icon(Icons.check, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 8),
                      Tooltip(
                        message: 'Reject',
                        child: ElevatedButton(
                          onPressed: () {
                            if (action == 'request') {
                              int id = item['requestid'];
                              update_request(id, 'Disapproved');
                            } else if (action == 'propertyreport') {
                              int id = item['p_report_id'];
                              update_propertyreport(id, 'disapproved');
                            } else if (action == 'agentreport') {
                              int id = item['a_report_id'];
                              update_agentreport(id, 'Disapprove');
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
