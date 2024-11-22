import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServicesUser {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> authenticateUser({
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
          throw Exception('Failed to authenticate user');
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
          throw Exception('Failed to create user');
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
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
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
}
