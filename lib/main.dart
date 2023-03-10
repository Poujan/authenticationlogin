import 'package:authenticationlogin/login_form.dart';
import 'package:authenticationlogin/register_form.dart';
import 'package:authenticationlogin/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'error_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyA-yIaFEh377gvOhApgQKbLfy8f0z6M6pk",
    projectId: "authentication-system-c245d",
    storageBucket: "authentication-system-c245d.appspot.com",
    messagingSenderId: "209557338451",
    appId: "1:209557338451:web:57acb8c6e1161f5e4f89a6",
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Authentication Login',
            home: LoginScreen(),
          );
        } else {
          return ErrorPage();
        }
      },
    );
  }
}
