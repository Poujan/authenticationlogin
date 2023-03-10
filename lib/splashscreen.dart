// import 'dart:async';

// import 'package:authenticationlogin/homepage.dart';
// import 'package:authenticationlogin/register_form.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'login_form.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     Timer(const Duration(seconds: 1), () {
//       FirebaseAuth.instance.authStateChanges().listen((User? user) {
//         if (user == null) {
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (BuildContext context) => const RegisterScreen()));
//         } else {
//           _checkSession();
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (BuildContext context) =>
//                       Homepage(email: user.email!)));
//         }
//       });
//     });
//     super.initState();
//   }

//   void _checkSession() async {
//     final user = FirebaseAuth.instance.currentUser;
//     final prefs = await SharedPreferences.getInstance();
//     final storedSessionID = prefs.getString('session_id');

//     if (user != null) {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.email)
//           .get();

//       if (snapshot.exists) {
//         final currentSessionID = snapshot.get('session_id');
//         if (storedSessionID == currentSessionID) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (_) => Homepage(
//                 email: user.email!,
//               ),
//             ),
//           );
//         } else {
//           await FirebaseAuth.instance.signOut().then((value) {
//             _showError('You have been logged out from another device/browser.');
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                 builder: (_) => const LoginScreen(),
//               ),
//             );
//           });
//           await prefs.remove('session_id');
//         }
//       }
//     }
//   }

//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }
