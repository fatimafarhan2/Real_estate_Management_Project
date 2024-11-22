import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/Profiles/sub_pages/HireAgent.dart';

class PropertyDetails extends StatefulWidget {
  const PropertyDetails({super.key});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  // Define TextEditingControllers for each input field
  final TextEditingController titleController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController installmentperiodController =
      TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    titleController.dispose();
    roomsController.dispose();
    addressController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: Text('Property Details'),
        centerTitle: true,
        backgroundColor: buttonColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            width: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add new Property',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // TextFields with green background color
                buildTextField('Title', 'Enter Title', titleController),
                buildTextField('Number Of Rooms', 'Enter Number of rooms',
                    roomsController),
                buildTextField('Address', 'Enter Address', addressController),
                buildTextField('Price', 'Enter Price', priceController),
                buildTextField(
                    'Description', 'Enter Description', descriptionController),
                buildTextField('Max Installment Time Period',
                    'Enter timeperiod (Months)', installmentperiodController),
                const SizedBox(height: 5),

                const Text(
                  'Hire Your Agent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Hireagent()),
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text(
                    'Hire Agent',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: drawerBoxColor,
                    iconColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0), // Padding
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Placeholder for submit action
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
      ),
    );
  }

  Widget buildTextField(
      String label, String placeholder, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(
                255, 178, 190, 74), // Set background color to light green

            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              border: InputBorder.none, // Removes the default border
            ),
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
