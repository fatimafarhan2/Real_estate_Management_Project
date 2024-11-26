import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your custom styles and colors
import 'package:real_estate_app/UI/textstyle.dart';
import '../UI/color.dart';

class OfferForm extends StatefulWidget {
  final double price;
  final String interval_mon;
  final String agentid;
  final String buyerid;
  final int property_id;

  const OfferForm({
    super.key,
    required this.price,
    required this.property_id,
    required this.interval_mon,
    required this.agentid,
    required this.buyerid,
  });

  @override
  State<OfferForm> createState() => _OfferFormState();
}

class _OfferFormState extends State<OfferForm> {
  String selectedOption = "Installments";
  double installmentPeriod = 1; // Default to 1 month
  double offerAmount = 0.0; // Default offer amount

  final TextEditingController offerAmountController = TextEditingController();

  double get calculatedInstallmentPrice {
    // Calculate installment price based on selected option and offer amount
    if (selectedOption == "Both" && offerAmount > 0) {
      return offerAmount / installmentPeriod;
    } else if (selectedOption == "Installments") {
      return widget.price / installmentPeriod;
    }
    return 0.0;
  }

  @override
  void dispose() {
    offerAmountController.dispose();
    super.dispose();
  }

  Future<void> submitOffer() async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.rpc('insert_offer_with_defaults', params: {
        '_buyer_id': widget.buyerid,
        '_agent_id': widget.agentid,
        '_property_id': widget.property_id,
        '_installment_amount': selectedOption != 'Full Price Bargain'
            ? calculatedInstallmentPrice
            : 0.0,
        '_installment_time_period': selectedOption != 'Full Price Bargain'
            ? installmentPeriod.round()
            : 0,
        '_total_price':
            selectedOption == 'Full Price Bargain' || selectedOption == 'Both'
                ? offerAmount
                : 0.0,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Offer submitted successfully!')),
      );

      // Optionally navigate back or reset the form
    } catch (error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting offer: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text('Offer Form'),
        centerTitle: true,
        backgroundColor: buttonColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Place new offer',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              // Dropdown menu
              DropdownButton<String>(
                dropdownColor: scaffoldColor,
                isDense: true,
                underline: Container(
                  height: 2,
                  color: boxcolor,
                ),
                value: selectedOption,
                items: <String>['Installments', 'Full Price Bargain', 'Both']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue!;
                    offerAmount = 0.0; // Reset offer amount
                    offerAmountController.clear(); // Clear text field
                  });
                },
              ),
              SizedBox(height: 20),

              // Conditional fields based on selected option
              if (selectedOption == 'Installments')
                Container(
                  height: 30,
                  child: Text(
                    'Installment Price: \$${calculatedInstallmentPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              if (selectedOption == 'Full Price Bargain' ||
                  selectedOption == 'Both')
                TextFormField(
                  controller: offerAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    fillColor: boxcolor,
                    labelText: 'Offer Amount',
                    hintText: 'Enter amount',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      offerAmount = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              if (selectedOption == 'Both' && offerAmount > 0)
                Container(
                  height: 30,
                  child: Text(
                    'Installment Price: \$${calculatedInstallmentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

              // Shared Installment Period Slider
              if (selectedOption != 'Full Price Bargain')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20.0),
                    Text(
                      'Installment Period: ${installmentPeriod.round()} months',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: installmentPeriod,
                      min: 1.0,
                      max: (widget.interval_mon != "00:00:00" &&
                              widget.interval_mon.isNotEmpty)
                          ? double.tryParse(widget.interval_mon) ?? 24
                          : 24, // Default to 24 months if interval_mon is invalid
                      divisions: ((widget.interval_mon != "00:00:00" &&
                                  widget.interval_mon.isNotEmpty)
                              ? (int.tryParse(widget.interval_mon) ?? 24)
                              : 24) -
                          1,
                      onChanged: (newPeriod) {
                        setState(() {
                          installmentPeriod = newPeriod;
                        });
                      },
                      activeColor: buttonColor,
                      inactiveColor: boxcolor,
                    ),
                  ],
                ),

              const SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    submitOffer();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 50),
                    backgroundColor: buttonColor,
                  ),
                  child: const Text(
                    'Submit',
                    style: tbutton_style,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
