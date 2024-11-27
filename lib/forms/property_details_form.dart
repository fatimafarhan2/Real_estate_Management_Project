import 'package:flutter/material.dart';
import 'package:real_estate_app/Chat/pages/agentlist.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/Profiles/sub_pages/HireAgent.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_estate_app/forms/Globalvariable.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyDetails extends StatefulWidget {
  const PropertyDetails({super.key});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  // Define TextEditingControllers for each input field
  final TextEditingController titleController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController bathroomController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController installmentPeriodController =
      TextEditingController();
  String agentHire = '';
  String? fPath;

  Globalvariable hiredAgent = Globalvariable();

  final storage = Supabase.instance.client.storage;
  final SupabaseClient client = Supabase.instance.client;
  String userid = '';
  // Uploading profile image
  File? _imageFile;

  // Pick image method
  List<File> _imageFiles = []; // List to hold picked image files

  // Dropdown variables
  int? selectedCategoryId; // Selected category ID
  String? selectedCity; // Selected city
  final List<String> predefinedCities = [
    'Multan',
    'Karachi',
    'Islamabad',
    'Lahore',
    'Peshawar',
    'Quetta',
    'Hyderabad',
  ];
  List<Map<String, dynamic>> categories = [];

  // Pick multiple images
  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        _imageFiles = images.map((image) => File(image.path)).toList();
      });
    } else {
      debugPrint('No images selected');
    }
  }

  Future<void> fetchUserProperties() async {
    List<Map<String, dynamic>> properties = [];

    final user = Supabase.instance.client.auth.currentUser;
    try {
      final data = await client.from('properties').select('''
          title,
          price,
          status,
          category:property_category (
            category_name
          )
        ''').eq('seller_id', user.toString());

      if (data == null || data.isEmpty) {
        print('No properties found for this agent.');
      } else {
        setState(() {
          print(data);
          properties = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetching agent properties: $e');
    }
  }

  Future<void> getCurrentUserId() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      userid = user.id;
      print('Current User ID: $userid');
    } else {
      print('No user is currently logged in');
    }
  }

  Future<void> fetchAllCategories() async {
    try {
      final response = await client
          .from('property_category')
          .select('category_id, category_name');

      if (response == null || response.isEmpty) {
        print('Error fetching categories:');
        return;
      }

      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<List<String>> uploadImages(String propertyId) async {
    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images to upload')),
      );
      return [];
    }

    List<String> uploadedUrls = [];
    final folderPath = 'uploads/$propertyId';

    try {
      for (File imageFile in _imageFiles) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final filePath = '$folderPath/$fileName';

        await Supabase.instance.client.storage
            .from('ProfilePictures')
            .upload(filePath, imageFile);

        final publicUrl = Supabase.instance.client.storage
            .from('ProfilePictures')
            .getPublicUrl(filePath);

        uploadedUrls.add(publicUrl);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Uploaded ${_imageFiles.length} images successfully')),
      );

      setState(() {
        _imageFiles.clear();
      });

      return uploadedUrls;
    } catch (e) {
      debugPrint('Error uploading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload images')),
      );
      return [];
    }
  }

  Future<void> addPropertyAndRequest({
    required int numOfRoom,
    required String title,
    required String sellerId,
    required int numOfBathroom,
    required int categoryId,
    required String agentId,
    required double price,
    required String city,
    required double area,
    required String maxTimePeriod,
    required String description,
    required String address,
  }) async {
    try {
      print(userid);
      final response = await client.rpc('add_property_and_request', params: {
        'p_num_of_room': numOfRoom,
        'p_title': title,
        'p_seller_id': sellerId,
        'p_num_of_bathroom': numOfBathroom,
        'p_category_id': categoryId,
        'p_agent_id': agentId,
        'p_price': price,
        'p_city': city,
        'p_area': area,
        'p_max_time_period': maxTimePeriod,
        'p_description': description,
        'p_address': address,
      });

      if (response == null) {
        print('Error: Response from the RPC call is null.');
      } else if (response.error != null) {
        print('Error: ${response.error!.message}');
      } else {
        print('Property and request added successfully!');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    fetchAllCategories();
  }

  @override
  void dispose() {
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

                buildTextField('Title', 'Enter Title', titleController),
                buildTextField('Number Of Rooms', 'Enter Number of rooms',
                    roomsController),
                buildTextField('Number Of Bathrooms',
                    'Enter Number of bathrooms', bathroomController),
                buildTextField('Address', 'Enter Address', addressController),
                buildTextField('Price', 'Enter Price', priceController),
                buildTextField('Area ', 'Enter Area sq.ft', areaController),
                buildTextField(
                    'Description', 'Enter Description', descriptionController),
                buildTextField('Max Installment Time Period',
                    'format: number (Months)', installmentPeriodController),

                const SizedBox(height: 10),

                // Dropdown for Category
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category['category_id'],
                      child: Text(category['category_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    filled: true,
                    fillColor: Color.fromARGB(255, 178, 190, 74),
                  ),
                  hint: const Text('Select a Category'),
                ),

                const SizedBox(height: 10),

                // Dropdown for City
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  items: predefinedCities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select City',
                    filled: true,
                    fillColor: Color.fromARGB(255, 178, 190, 74),
                  ),
                  hint: const Text('Select a City'),
                ),

                const SizedBox(height: 20),

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
                          builder: (context) => const AgentListPage()),
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

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: drawerBoxColor,
                  ),
                  onPressed: () async {
                    if (selectedCategoryId == null ||
                        selectedCity == null ||
                        titleController.text.isEmpty ||
                        priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please fill all fields and select dropdowns!')),
                      );
                      return;
                    }

                    await addPropertyAndRequest(
                      numOfRoom: int.parse(roomsController.text),
                      title: titleController.text,
                      sellerId: userid,
                      numOfBathroom: int.parse(bathroomController.text),
                      categoryId: selectedCategoryId!,
                      agentId: hiredAgent.agent_id,
                      price: double.parse(priceController.text),
                      city: selectedCity!,
                      area: double.parse(areaController.text),
                      maxTimePeriod:
                          '${installmentPeriodController.text} months',
                      description: descriptionController.text,
                      address: addressController.text,
                    );

                    // Refresh profile data after adding the property
                    await fetchUserProperties();
                    // Optionally, navigate to the profile page or display a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Property added successfully!')),
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Submit',style: tbutton_style,),
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
