import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_estate_app/Profiles/sub_pages/viewAgent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgentListPage extends StatelessWidget {
  const AgentListPage({super.key});

  // Function to fetch the agent_id based on the email from Supabase
  Future<String> getAgentIdByEmail(String email) async {
    final supabase = Supabase.instance.client;

    // Query Supabase to fetch the agent_id for the given email
    final response = await supabase
            .from('agent') // Your Supabase table for agents
            .select('agent_id')
            .eq('email', email) // Match the email
            .single() // We only expect one agent with this email
        ;

    // Check if the response is empty or has an error
    if (response == null || response.isEmpty) {
      throw Exception('Error fetching agent ID or agent not found.');
    }

    // Return the agent_id (it should be present)
    final agentId = response['agent_id'] as String?;
    return agentId ??
        'No agent found'; // Return 'No agent found' if no match is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agents")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('agents').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final agents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              final agentEmail = agent['email'] ?? 'No email available';

              // Get agent ID from Supabase based on email
              Future<String> agentid = getAgentIdByEmail(agent['email']);

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  title: Text(
                    agentEmail,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      agentid.then((id) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAgent(
                              agentid: id,
                              role: 'user',
                              firebaseagentid: agent.id,
                            ),
                          ),
                        );
                      });
                    },
                    child: const Text("View Profile"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
