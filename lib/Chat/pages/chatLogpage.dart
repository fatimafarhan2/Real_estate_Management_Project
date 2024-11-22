import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_app/Chat/pages/chatpage.dart';

class UserChatLogPage extends StatelessWidget {
  final String userId;

  UserChatLogPage({required this.userId});

  // Function to fetch the agent's email
  Future<String> getAgentEmail(String agentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('agents')
          .doc(agentId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        print(data?['email']);
        return data?['email'] ?? 'No Email Found';
      } else {
        return 'User Not Found';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Log")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;
          print(chats);
          // Handle case where there are no chats
          if (chats.isEmpty) {
            return const Center(child: Text("No chats found."));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = List<String>.from(chat['participants']);
              final agentId = participants.firstWhere((id) => id != userId);

              return FutureBuilder<String>(
                future: getAgentEmail(agentId), // Fetch the email of the agent
                builder: (context, emailSnapshot) {
                  if (emailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Loading..."),
                    );
                  }

                  if (emailSnapshot.hasError) {
                    return ListTile(
                      title: Text("Error: ${emailSnapshot.error}"),
                    );
                  }

                  final agentEmail = emailSnapshot.data!;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        "$agentEmail",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      subtitle: Text(chat['lastMessage'] ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              sender: 'user',
                              userId: userId,
                              agentId: agentId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
