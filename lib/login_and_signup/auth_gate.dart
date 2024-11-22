import 'package:flutter/material.dart';
import 'package:real_estate_app/Admin/admin.dart';
import 'package:real_estate_app/Profiles/agent_profile.dart';
import 'package:real_estate_app/Profiles/user_profile.dart';
import 'package:real_estate_app/login_and_signup/login_signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override

  //iniit state function
  void initState() {
    super.initState();
    _supabase.auth.onAuthStateChange.listen((event) {
      setState(() {});
    });
  }

  Future<Widget> _redirectToCorrectDashboard() async {
    final user = _supabase.auth.currentUser;

    if (user != null) {
      // Fetch the user's role from the 'profiles' table
      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      // Navigate based on role
      // ignore: unnecessary_null_comparison
      if (profile != null) {
        final role = profile['role'];
        if (role == 'admin') {
          return const Admin();
        } else if (role == 'agent') {
          return const AgentProfile();
        } else if (role == 'user') {
          return UserProfile(role: 'user', userid: user.id);
        }
      }
    }
    // If no user is logged in or profile role is not found
    return const LoginSignUp();
  }

  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _redirectToCorrectDashboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong!')),
          );
        } else {
          // Navigate to the respective dashboard
          return snapshot.data!;
        }
      },
    );
  }
}
