import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/textstyle.dart';

class ListViewCard extends StatelessWidget {
  const ListViewCard({
    super.key,
    required this.filteredItems,
    required this.fieldLabels,
    required this.fieldKeys,
  });

  final List<Map<String, dynamic>> filteredItems;
  final List<String> fieldLabels; // Field labels to show in the UI
  final List<String> fieldKeys; // Keys corresponding to field data in each item

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
                            // Approve action
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
