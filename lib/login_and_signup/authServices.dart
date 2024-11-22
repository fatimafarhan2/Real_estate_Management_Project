import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gate.dart';

class Authservices {
  final SupabaseClient _supabase = Supabase.instance.client;
//SIGN UP FUNCTION
  Future<bool> signUpUserAgent(
    String role,
    String address,
    String firstName,
    String username,
    String lastName,
    String phoneNumber,
    String email,
    String password,
    double price, //for agent
    BuildContext context,
  ) async {
    try {
      //sign up real code
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user; //returns uuid

      if (user != null) {
        // Insert user details into the profiles table
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': email,
          'role': role,
        });

        // Insert into respective tables based on role
        if (role == 'user') {
          await _supabase.from('client').insert({
            'client_id': user.id,
            'email': email,
            'firstname': firstName,
            'lastname': lastName,
            'password': password,
            'phonenumber': phoneNumber,
            'address': address,
            'username': username
          });
        } else if (role == 'agent') {
          await _supabase.from('agent').insert({
            'agent_id': user.id,
            'email': email,
            'f_name': firstName,
            'l_name': lastName,
            'password': password,
            'phone_number': phoneNumber,
            'price': price,
            'client_id': null,
            'username': username
          });
        }

        print('User signed up successfully');

        // Ensure the widget is still mounted before using context
        if (context.mounted) {
          // After successful sign up, navigate back to AuthGate
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthGate()),
          );
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error in sign up: $e");
      return false;
    }
  }

  Future<int> loginUser(
      BuildContext context, String email, String password, String role) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      final currUser = Supabase.instance.client.auth.currentUser;
      final roleResponse = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', currUser?.id as Object)
          .single();

      String? userrole = roleResponse['role'];
      print(userrole);

      if (role != userrole) {
        return 4;
      }

      if (user != null) {
        // AuthGate will handle the role-based navigation
        print('User logged in successfully');

        // Ensure the widget is still mounted before using context
        if (context.mounted) {
          // After successful login, navigate to AuthGate
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthGate()),
          );
        }
        return 0; //case of logging in  sucessfully
      } else {
        print("Error in finding user");
        return 1; //case user does not exist
      }
    } catch (e) {
      print("Error logging in: $e");
      return 2; // case of error in loggin in process
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut(); // Sign out from Supabase
    } catch (e) {
      throw Exception("Error signing out: $e");
    }
  }
}
