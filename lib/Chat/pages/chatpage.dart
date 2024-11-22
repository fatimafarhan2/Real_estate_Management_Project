import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  late String chatId;

  @override
  void initState() {
    super.initState();
    // Generate chat ID
    chatId = "${widget.userId}_${widget.agentId}";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                          color: isSentByUser ? Colors.blue : Colors.grey[300],
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
        ],
      ),
    );
  }
}
