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
      // Get Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query the 'agents' collection to find the document by email
      QuerySnapshot querySnapshot = await firestore
          .collection('agents')
          .where('email', isEqualTo: agentEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If the agent with the email exists, get the document reference
        DocumentSnapshot agentDoc = querySnapshot.docs.first;

        // Delete the agent document
        await agentDoc.reference.delete();

        print('Agent deleted successfully');
      } else {
        print('No agent found with email: $agentEmail');
      }
    } catch (e) {
      print('Error deleting agent: $e');
    }
  }
}
