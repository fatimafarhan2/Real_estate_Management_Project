import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_estate_app/Chat/pages/appointment.dart';
import 'package:real_estate_app/UI/color.dart';
import 'package:real_estate_app/forms/Globalvariable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String agentId;
  final String sender;
  const ChatPage({
    Key? key,
    required this.userId,
    required this.sender,
    required this.agentId,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? agentEmail;
  String? agentSupabaseId;
  String? clientSupabaseId;
  late String chatId;

//--------------------------------------------

  Future<String?> getAgentIdFromSupabase(String email) async {
    try {
      final response = await Supabase.instance.client
          .from('agent') // Replace 'agents' with your Supabase table name
          .select('agent_id') // Replace 'agent_id' with the actual column name
          .eq('email', email)
          .single(); // Ensures only one record is fetched

      if (response != null && response is Map<String, dynamic>) {
        return response[
            'agent_id']; // Replace with the column containing agent ID
      } else {
        print("No matching agent found in Supabase.");
        return null;
      }
    } catch (e) {
      print("Error fetching agent ID from Supabase: $e");
      return null;
    }
  }

// --------------------------------------------------------------
  Future<String?> getAgentEmailFromFirestore(String agentId) async {
    try {
      final agentDoc = await FirebaseFirestore.instance
          .collection('agents')
          .doc(agentId)
          .get();

      if (agentDoc.exists) {
        final data = agentDoc.data();
        return data?['email']; // Assumes the document has an 'email' field
      } else {
        print("Agent document does not exist.");
        return null;
      }
    } catch (e) {
      print("Error fetching agent email: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Generate chat ID
    chatId = "${widget.userId}_${widget.agentId}";
    fetchAgentDetails();
  }

  Future<void> fetchAgentDetails() async {
    try {
      final email = await getAgentEmailFromFirestore(widget.agentId);
      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Agent email not found in Firestore.")),
        );
        return;
      }
      final supabaseId = await getAgentIdFromSupabase(email);
      if (supabaseId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Agent ID not found in Supabase.")),
        );
        return;
      }

      setState(() {
        agentEmail = email;
        agentSupabaseId = supabaseId;
        print('supabase agent id:${agentSupabaseId}');
      });
    } catch (e) {
      print("Error fetching agent details: $e");
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      // Ensure the chat document exists
      await _firestore.collection('chats').doc(chatId).set({
        "participants": [widget.userId, widget.agentId],
        "lastMessage": messageText,
      }, SetOptions(merge: true));

      final time = Timestamp.now();

      // Determine sender based on who is the user

      String senderId = widget.userId; // Default sender is user
      if (widget.sender == 'agent') senderId = widget.agentId; // If it's agent

      print(senderId);
      // Update the chat with the new message and timestamp
      await _firestore.collection('chats').doc(chatId).update({
        "lastMessageTime": FieldValue.serverTimestamp(),
        "messages": FieldValue.arrayUnion([
          {
            "sender": senderId, // This will be either userId or agentId
            "text": messageText,
            "timestamp": time,
          }
        ])
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending message: $e")),
      );
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      // Get the current user from Supabase
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        clientSupabaseId = user.id;
        print("Current User ID: ${user.id}");
      } else {
        print("No user is currently logged in.");
      }

      return user;
    } catch (e) {
      print("Error fetching current user: $e");
      return null;
    }
  }
  //     APPOINTMENT
// ------------------------------------------------------------------//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: scaffoldColor,
        title: const Text("Chat"),
      ),
      body: Column(
        children: [
          // Chat Messages List
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('chats').doc(chatId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("No messages yet."));
                }

                final chatData = snapshot.data!.data() as Map<String, dynamic>;
                final messages = chatData['messages'] ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isSentByUser = message['sender'] == widget.userId;

                    return Align(
                      alignment: isSentByUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSentByUser ? boxcolor : Colors.green[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isSentByUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      filled: true, // Enables the fill color
                      fillColor:
                          boxcolor, // Set the background color of the TextField
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              // Ensure both IDs are available
              if (agentSupabaseId == null || clientSupabaseId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Fetching details, please wait...")),
                );

                // Fetch details again if they are null
                await fetchAgentDetails();
                await getCurrentUser();
              }

              if (agentSupabaseId != null && clientSupabaseId != null) {
                Appointment ap = Appointment();
                ap.setAppointment(
                  agentId: agentSupabaseId!,
                  clientId: clientSupabaseId!,
                  context: context,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Unable to fetch necessary details.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: scaffoldColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('Set Appointment'),
          ),
        ],
      ),
    );
  }
}
