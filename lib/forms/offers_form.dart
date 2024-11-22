import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import '../UI/color.dart';

double Price = 12345;

class OfferForm extends StatefulWidget {
  const OfferForm({super.key});

  @override
  State<OfferForm> createState() => _OfferFormState();
}

class _OfferFormState extends State<OfferForm> {
  String selectedOption = "Installments";
  double installmentPeriod = 1; // Default to 1 month
  double offerAmount =
      0.0; // Value for entered offer amount , this is by default

  final TextEditingController offerAmountController = TextEditingController();

  double get calculatedInstallmentPrice {
    // Calculate based on selected option and offer amount
    if (selectedOption == "Both" && offerAmount > 0) {
      return offerAmount / installmentPeriod;
    } else if (selectedOption == "Installments") {
      return Price / installmentPeriod;
    }
    return 0.0;
  }

  @override
  void dispose() {
    offerAmountController.dispose();
    super.dispose();
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
              Center(
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
                    //with every new option the offer amount becomes 0.0 and text field becomes clear
                    offerAmount = 0.0; // Reset offer amount on option change
                    offerAmountController.clear(); // Clear the text field
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
                  decoration: InputDecoration(
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      max: 24.0,
                      divisions: 23,
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

              SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Placeholder for submit action
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 50),
                    backgroundColor: buttonColor,
                  ),
                  child: Text(
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
