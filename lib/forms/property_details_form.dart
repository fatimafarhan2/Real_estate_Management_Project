 import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:real_estate_app/Profiles/sub_pages/HireAgent.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController installmentperiodController =TextEditingController();
String? fPath;
final storage = Supabase.instance.client.storage;
final SupabaseClient client = Supabase.instance.client;
//kuploading profile image
File? _imageFile;
//Pick image method
List<File> _imageFiles = []; // List to hold picked image files
// Pick multiple images
Future<void> pickImages() async {
  final ImagePicker picker = ImagePicker();

  // Pick multiple images
  final List<XFile>? images = await picker.pickMultiImage();

  if (images != null && images.isNotEmpty) {
    setState(() {
      // Convert selected images to File and store in the list
      _imageFiles = images.map((image) => File(image.path)).toList();
    });
  } else {
    debugPrint('No images selected');
  }
}


//upload method
// Upload method
// Upload multiple images
Future<List<String>> uploadImages(String propertyId) async {
  if (_imageFiles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No images to upload')),
    );
    return [];
  }

  List<String> uploadedUrls = []; // To store the URLs of uploaded images
  final folderPath = 'uploads/$propertyId'; // Folder named after propertyId

  try {
    for (File imageFile in _imageFiles) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Unique file name
      final filePath = '$folderPath/$fileName'; // Path in the bucket

      // Upload the image file to Supabase storage
      await Supabase.instance.client.storage
          .from('ProfilePictures') // Bucket name
          .upload(filePath, imageFile);

      // Get the public URL of the uploaded image
      final publicUrl = Supabase.instance.client.storage
          .from('ProfilePictures')
          .getPublicUrl(filePath);

      uploadedUrls.add(publicUrl);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploaded ${_imageFiles.length} images successfully')),
    );

    setState(() {
      _imageFiles.clear(); // Clear the list after upload
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

//extractin url of user's upload image
  Future<String?> fetchImageUrl(String filePath) async {
    try {
      final publicUrl = client.storage
          .from('ProfilePictures') // Bucket name
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error fetching public URL: $e');
      return null;
    }
  }


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
                
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                     // await pickImage(); // Open image picker
                        //extracting image url:modified
                     // await uploadImage(); // Upload the image to Supabase
                      print(fPath);
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload Images of your property', style: tbutton_style,),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),


               const Text(
                      'Hire Your Agent',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                    onPressed: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Hireagent()),
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
            color: const Color.fromARGB(255, 178, 190, 74), // Set background color to light green
            
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
