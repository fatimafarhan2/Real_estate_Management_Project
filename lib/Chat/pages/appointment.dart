import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Appointment {
  Future<void> setAppointment({
    required BuildContext context,
    required String agentId,
    required String clientId,
  }) async {
    TextEditingController dateController = TextEditingController();
    TextEditingController addressController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Enter Date',
                hintText: 'MM/DD/YYYY',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Enter Address',
                hintText: '123 Main St',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              String date = dateController.text;
              String address = addressController.text;

              if (date.isEmpty || address.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Both fields are required!")),
                );
                return;
              }

              Navigator.of(context).pop(); // Close the dialog first
              saveAppointment(
                date: date,
                address: address,
                clientId: clientId,
                agentId: agentId,
                scaffoldContext: context, // Use the correct context here
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> saveAppointment({
    required String date,
    required String address,
    required String clientId,
    required String agentId,
    required BuildContext scaffoldContext, // Use a valid context here
  }) async {
    try {
      final response =
          await Supabase.instance.client.from('appointments').insert({
        'date': date,
        'meet_address': address,
        'buyer_id': clientId,
        'agent_id': agentId,
      });

      if (response.error != null) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(content: Text("Failed to save the appointment.")),
        );
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(content: Text("Appointment saved successfully.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(content: Text("Error saving appointment: $e")),
      );
    }
  }
}
