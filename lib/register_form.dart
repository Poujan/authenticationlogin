import 'package:authenticationlogin/homepage.dart';
import 'package:authenticationlogin/login_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bcrypt/bcrypt.dart';

import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  static const String id = 'Login-Screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  void dispose() {
    _showMyDialog();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check if username is unique and not less than four characters
      final username = _usernameController.text.trim();
      if (username.length < 4) {
        throw 'Username must be at least four characters';
      }
      final usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (usernameQuery.docs.isNotEmpty) {
        throw 'Username is already taken';
      }

      // Check if email is valid and unique
      final email = _emailController.text.trim();
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(email)) {
        throw 'Email is not valid';
      }
      final emailQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (emailQuery.docs.isNotEmpty) {
        throw 'Email is already registered';
      }

      // Check if password is not less than six characters and contains a number and an uppercase letter
      final password = _passwordController.text;
      final passwordRegExp =
          RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}$');
      if (!passwordRegExp.hasMatch(password)) {
        throw 'Password must be at least six characters and contain an uppercase letter and a number';
      }
      await authenticateStudent();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future authenticateStudent() async {
    var currentStudent;

    String appName = 'temporary name';
    FirebaseApp tempApp = await Firebase.initializeApp(
        name: appName, options: Firebase.app().options);
    FirebaseAuth.instanceFor(app: tempApp)
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )
        .then((auth) async {
      currentStudent = auth.user;

      if (currentStudent != null) {
        // Generate salt for hashing

        saveDataToFirestore(currentStudent!).then((value) async {
          Navigator.pop(context);
          print("User added successfully");
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      } else {
        _showMyDialog(
            title: "Add new User Failed",
            message: 'There was an error while trying to save the new user!');
      }
    }).catchError((onError) {
      _showMyDialog(
          title: "Add new User Failed", message: 'User already exists!');
    });
  }

  Future saveDataToFirestore(User currentStudent) async {
    final String passwordHashed = BCrypt.hashpw(
      _passwordController.text.trim(),
      BCrypt.gensalt(),
    );
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentStudent.email)
        .set({
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': passwordHashed,
      'session_id': '',
    });
  }

  Future<void> _showMyDialog({title, message}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                const Text('Please Try Again!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Login', style: TextStyle(color: Colors.white)))
        ],
        elevation: 0.0,
        title: const Text(
          'Sample Authentication System',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue,
              Color.fromARGB(255, 255, 255, 255),
            ],
            stops: [1.0, 1.0],
            begin: Alignment.topCenter,
            end: Alignment(0.0, 0.0),
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 450,
            height: 550,
            child: Card(
              elevation: 6,
              shape: Border.all(color: Colors.lightBlue, width: 3),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Column(
                            children: [
                              Image.asset('assets/images/utm.png'),
                              const SizedBox(
                                height: 30,
                              ),
                              TextFormField(
                                controller: _usernameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  icon: Icon(Icons.person),
                                  // hintText: 'Umail',
                                  contentPadding:
                                      EdgeInsets.only(left: 20, right: 10),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.lightBlue, width: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  icon: Icon(Icons.email),
                                  // hintText: 'Umail',
                                  contentPadding:
                                      EdgeInsets.only(left: 20, right: 10),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.lightBlue, width: 2),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  icon: Icon(Icons.lock),
                                  // hintText: 'Password',
                                  contentPadding:
                                      EdgeInsets.only(left: 20, right: 10),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.lightBlue, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (_errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                padding: const EdgeInsets.all(16.0),
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _register();
                                }
                              },
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
