import 'dart:io';

import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewOffers extends StatefulWidget {
  final String agentid;

  const ViewOffers({Key? key, required this.agentid}) : super(key: key);

  @override
  _ViewOffersState createState() => _ViewOffersState();
}

class _ViewOffersState extends State<ViewOffers> {
  List<Map<String, dynamic>> offers = []; // Store fetched offers
  bool isLoading = true;
  String offerid = '';
  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> setOfferstatus(int offerId, String status) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('offers').update(
              {'offer_status': status}) // Update the status to 'disapproved'
          .eq('offer_id', offerId); // Filter by offer_id

      if (response == null) {
        // Update the UI after the status update
        fetchOffers();
        // print('Offer $offerId disapproved successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Offer $status  Successfuly')),
        );
      } else {
        print('Failed to disapprove the offer.');
      }
    } catch (error) {
      print('Error updating status: $error');
    }
  }

  Future<void> fetchOffers() async {
    final supabase = Supabase.instance.client;

    try {
 final response = await supabase
    .from('offers')
    .select('*, client(username), properties(title)') // Select fields
    .eq('agent_id', widget.agentid) // Filter by agent_id
    .neq('offer_status', 'Approved'); // Only select offers where offer_status is not 'Approved'

      if (response != null && response is List) {
        // Map response into the offers list
        setState(() {
          offers = response.map((offer) {
            return {
              'Property Name': offer['properties']['title'] ?? 'Unknown',
              'Buyer Name': offer['client']['username'] ?? 'Anonymous',
              'Installment Amount': offer['installment_amount'] ?? '',
              'Installment Time Period': offer['installment_time_period'] ?? '',
              'Bargain Price': offer['total_price'] ?? '',
              'offer id': offer['offer_id'] ?? '',
            };
          }).toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching offers: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Offers',
          style: tappbar_style,
        ),
        backgroundColor: buttonColor,
      ),
      backgroundColor: propertyBGColor,
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show a loader while fetching data
          : offers.isEmpty
              ? const Center(
                  child: Text('No Offers Received...', style: tUserBody))
              : ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Property Name: ${offer['Property Name']}',
                                style: tAppointmentBody,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Buyer Name: ${offer['Buyer Name']}',
                                style: tUserBody,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Installment Amount: ${offer['Installment Amount']}',
                                style: tUserBody,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Installment Time Period: ${offer['Installment Time Period']}',
                                style: tUserBody,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Bargain Price: ${offer['Bargain Price']}',
                                style: tUserBody,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      int offerid = offers[index]['offer id'];
                                      setOfferstatus(offerid, 'Approved');
                                      // Add logic for approving the offer
                                      print('Offer approved: ${offer}');
                                    },
                                    icon: const Icon(Icons.check),
                                    label: const Text('Approve'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Add logic for rejecting the offer
                                      int offerid = offers[index]['offer id'];
                                      setOfferstatus(offerid, 'Disapproved');
                                      print('Offer rejected: ${offer}');
                                    },
                                    icon: const Icon(Icons.close),
                                    label: const Text('Reject'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
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
                ),
    );
  }
}
