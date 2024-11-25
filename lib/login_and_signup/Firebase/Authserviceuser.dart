import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServicesUser {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> authenticateUser({
    required String email,
    required String password,
    required bool isLogin,
    required String role,
  }) async {
    try {
      UserCredential userCredential;

      // Validate role
      if (role != 'agent' && role != 'user') {
        throw Exception('Invalid role provided');
      }

      if (isLogin) {
        // Sign In
        print('Attempting to sign in...');
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user == null) {
          return false;
        }

        DocumentReference userDoc = _firestore
            .collection(role == 'agent' ? 'agents' : 'users')
            .doc(user.uid);

        bool docExists = false;
        try {
          docExists = await userDoc.get().then((doc) => doc.exists);
        } catch (e) {
          print('Error checking user document: $e');
        }

        if (!docExists) {
          await userDoc.set({
            'email': email,
            'lastLogin': FieldValue.serverTimestamp(),
            'role': role,
          });
        } else {
          await userDoc.update({'lastLogin': FieldValue.serverTimestamp()});
        }
      } else {
        // Register new user
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user == null) {
          return false;
        }

        await _firestore
            .collection(role == 'agent' ? 'agents' : 'users')
            .doc(user.uid)
            .set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': role,
        });
      }

      // Return true if everything was successful
      return true;
    } on FirebaseAuthException catch (e) {
      // Log error or handle it
      print('Authentication error: $e');
      return false;
    }
  }

  // Logout function
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print("User logged out successfully");
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> deleteAgentByEmail(String agentEmail) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query the 'agents' collection to find the document by email
      QuerySnapshot querySnapshot = await firestore
          .collection('agents')
          .where('email', isEqualTo: agentEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If the agent with the email exists, get the document reference
        DocumentSnapshot agentDoc = querySnapshot.docs.first;
        String agentId = agentDoc.id;

        // 1. Delete the agent document
        await agentDoc.reference.delete();
        print('Agent deleted successfully');

        // 2. Delete all chats associated with this agent
        QuerySnapshot chatsSnapshot = await firestore
            .collection('chats')
            .where('participants',
                arrayContains: agentId) // Find chats with agent as participant
            .get();

        for (var chatDoc in chatsSnapshot.docs) {
          // Delete each chat document where the agent is a participant
          await chatDoc.reference.delete();
          print('Deleted chat with agent as participant: ${chatDoc.id}');
        }
      } else {
        print('No agent found with email: $agentEmail');
      }
    } catch (e) {
      print('Error deleting agent: $e');
    }
  }

  Future<void> deleteUserByEmail(String userEmail) async {
    try {
      final firestore = FirebaseFirestore.instance;

      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        String userId = userDoc.id;

        // 1. Delete the user document from 'users' collection
        await userDoc.reference.delete();
        print('User deleted successfully');

        QuerySnapshot chatsSnapshot = await firestore
            .collection('chats')
            .where('participants',
                arrayContains: userId) // Find chats with user as participant
            .get();

        for (var chatDoc in chatsSnapshot.docs) {
          await chatDoc.reference.delete();
          print('Deleted chat with user as participant: ${chatDoc.id}');
        }
      } else {
        print('No user found with email: $userEmail');
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
