import 'package:authenticationlogin/login_form.dart';
import 'package:authenticationlogin/register_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    super.key,
    required this.email,
  });
  final String email;

  @override
  State<Homepage> createState() => _HomepageState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final User? user = _auth.currentUser;
final dateTime = user!.metadata.lastSignInTime!.toLocal();
final formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
final formattedTime = DateFormat('HH:mm').format(dateTime);

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0.0,
        title: const Center(child: Text('Homepage')),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome, ${widget.email}'),
            Text('Your last valid login is: $formattedDate at $formattedTime'),
            const SizedBox(height: 20.0),
            ElevatedButton(
              child: const Text('Sign Out'),
              onPressed: () async {
                await SharedPreferences.getInstance().then((prefs) {
                  prefs.remove('session_id');
                });
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
