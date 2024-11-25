import 'package:flutter/material.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/UI/textstyle.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileUpdatePage extends StatefulWidget {
  const UserProfileUpdatePage({super.key});

  @override
  _UserProfileUpdatePageState createState() => _UserProfileUpdatePageState();
}
class _UserProfileUpdatePageState extends State<UserProfileUpdatePage> {
  // (User data variables to store updated values)
  String username = 'Current Username';
  String address = 'Current Address';
  String phoneNumber = 'Current Phone Number';
    final SupabaseClient client = Supabase.instance.client;
    String? getCurrentUserIdAsString() {
  final user = Supabase.instance.client.auth.currentUser;
  return user?.id; // Returns the user's UUID as a String or null if not logged in
}


Future<void> _updateUserInfo(String toUpdate) async {
  try {
    String? userId = getCurrentUserIdAsString();
    if (userId == null) {
      throw Exception("User ID is null.");
    }

    final data;

    if (toUpdate == 'username') {
      data = await client.rpc('update_username', params: {
        'user_id': userId,
        'name': username, 
      });
    } else if (toUpdate == 'address') {
      data = await client.rpc('update_user_address', params: {
        'user_id': userId,
        'addrs': address,
      });
    } else if (toUpdate == 'number') {
      data = await client.rpc('update_user_number', params: {
        'user_id': userId,
        'number': phoneNumber, 
      });
    } else {
      throw Exception("Invalid update type: $toUpdate");
    }

    print("RPC call successful. Response: $data");
  } catch (e) {

    print('Error updating user information: $e');
  }
}

    


  // (Helper function to display input dialog and update values)
  Future<void> _showUpdateDialog({
    required BuildContext context,
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) async {
    TextEditingController inputController = TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title), // (Displays dialog title)
        content: TextField(
          controller: inputController, // (Input field controller for text entry)
          decoration: InputDecoration(
            hintText: 'Enter new $title', // (Hint text for user input)
            border: OutlineInputBorder(), // (Adds a border around the input field)
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // (Closes dialog without saving)
            },
            child: Text('Cancel', style: TextStyle(color: buttonColor)), // (Cancel button styled in green)
          ),
          ElevatedButton(
            onPressed: () {
              onSave(inputController.text); // (Saves the input value to the corresponding variable)
              Navigator.of(context).pop(); // (Closes dialog after saving)
            },
            style: ElevatedButton.styleFrom(backgroundColor: drawerBoxColor), // (Green background for Save button)
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Update Profile',style: tappbar_style)), // (Page title)
        backgroundColor: buttonColor, // (AppBar background color)
      ),
      backgroundColor: scaffoldColor
      ,

      body: Padding(
        padding: const EdgeInsets.all(16.0), // (Padding for the page content)
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, // (Centers the content vertically)
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // (Opens dialog to update username)
                  _showUpdateDialog(
                    context: context,
                    title: 'Username',
                    currentValue: username,
                    onSave: (value) {
                      setState(() {
                        username = value; // (Updates the username variable)
                      });
                      _updateUserInfo('username');
                    },
                  );
                },
                icon:const Icon(Icons.person), // (Person icon for Username button)
                label: const Text('Update Username'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // (Green background color)
                  foregroundColor: Colors.white, // (White text color)
                ),
              ),
              const SizedBox(height: 16), // (Spacing between buttons)
              ElevatedButton.icon(
                onPressed: () {
                  // (Opens dialog to update address)
                  _showUpdateDialog(
                    context: context,
                    title: 'Address',
                    currentValue: address,
                    onSave: (value) {
                      setState(() {
                        address = value; // (Updates the address variable)

                      });
                      _updateUserInfo('address');
                    },
                  );
                },
                icon: Icon(Icons.home), // (Home icon for Address button)
                label: Text('Update Address'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // (Green background color)
                  foregroundColor: Colors.white, // (White text color)
                ),
              ),
              SizedBox(height: 16), // (Spacing between buttons)
              ElevatedButton.icon(
                onPressed: () {
                  // (Opens dialog to update phone number)
                  _showUpdateDialog(
                    context: context,
                    title: 'Phone Number',
                    currentValue: phoneNumber,
                    onSave: (value) {
                      setState(() {
                        phoneNumber = value; // (Updates the phone number variable)
                      });
                      _updateUserInfo('number');
                    },
                  );
                },
                icon: Icon(Icons.phone), // (Phone icon for Phone Number button)
                label: Text('Update Phone Number'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor, // (Green background color)
                  foregroundColor: Colors.white, // (White text color)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
