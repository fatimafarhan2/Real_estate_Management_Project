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

              // Call your appointment storage function here
              saveAppointment(
                date: date,
                address: address,
                clientId: clientId,
                agentId: agentId,
              );

              Navigator.of(context).pop();
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
  }) async {
    try {
      // Insert the appointment into the "appointments" table
      final response = await Supabase.instance.client
          .from('appointments') // Replace with your table name
          .insert({
        'date': date,
        'meet_address': address,
        'buyer_id': clientId, // Replace with your actual column name
        'agent_id': agentId, // Replace with your actual column name
      });
    } catch (e) {
      print('Error saving appointment: $e');
    }
  }
}
