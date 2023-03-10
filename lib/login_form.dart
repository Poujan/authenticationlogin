import 'dart:async';

import 'package:authenticationlogin/homepage.dart';
import 'package:authenticationlogin/register_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';

// import '../widgets/loading_overlay.dart';
// import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String id = 'Login-Screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _sessionID;
  @override
  void initState() {
    super.initState();
    _initPrefs();
    SharedPreferences.getInstance().then((prefs) {
      final sessionID = prefs.getString('session_id');
      setState(() {
        _sessionID = sessionID;
      });
      _checkSession();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _forgetPasswordController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Password Reset Email Sent'),
              content:
                  const Text('Please check your email to reset your password.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          });
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Please check your email please!'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          });
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: TextFormField(
            controller: _forgetPasswordController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset Password'),
              onPressed: () {
                passwordReset();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  final _forgetPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  int _loginAttempts = 0;
  DateTime? _lockedUntil;
  bool _rememberMe = false;
  late SharedPreferences _prefs;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = _prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = _prefs.getString('email') ?? '';
        _passwordController.text = _prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> _saveCredentials(String email, String password) async {
    await _prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await _prefs.setString('email', email);
      await _prefs.setString('password', password);
    } else {
      await _prefs.remove('email');
      await _prefs.remove('password');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _loginbtn() async {
    try {
      // Check if username is unique and not less than four characters

      // Check if email is valid and unique
      final email = _emailController.text.trim();
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegExp.hasMatch(email)) {
        _showError('Email is not valid');
      }

      // Check if password is not less than six characters and contains a number and an uppercase letter
      final password = _passwordController.text;
      final passwordRegExp =
          RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}$');
      if (!passwordRegExp.hasMatch(password)) {
        _showError(
            'Password must be at least six characters and contain an uppercase letter and a number');
      }

      _submitForm();
    } catch (e) {
      _showError(
          'There was an issue when tring to log in! Please try again later!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(
          'Sample Authentication System',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child:
                  const Text('Register', style: TextStyle(color: Colors.white)))
        ],
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
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
                  width: 400,
                  height: 500,
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
                                      controller: _emailController,
                                      onSaved: (value) {
                                        setState(() {
                                          _emailController.text = value!;
                                        });
                                      },
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
                                        contentPadding: EdgeInsets.only(
                                            left: 20, right: 10),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.lightBlue,
                                              width: 2),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
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
                                        contentPadding: EdgeInsets.only(
                                            left: 20, right: 10),
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.lightBlue,
                                              width: 2),
                                        ),
                                      ),
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Remember me'),
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      padding: const EdgeInsets.all(16.0),
                                      textStyle: const TextStyle(fontSize: 20),
                                    ),
                                    onPressed: () async {
                                      // await _checkSessionIdAndSignOut();
                                      if (_formKey.currentState!.validate()) {
                                        if (_lockedUntil == null ||
                                            _lockedUntil!
                                                .isBefore(DateTime.now())) {
                                          _loginbtn();
                                        } else {
                                          int remainingSeconds = _lockedUntil!
                                              .difference(DateTime.now())
                                              .inSeconds;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Your account is locked for $remainingSeconds seconds due to multiple failed login attempts.'),
                                              duration:
                                                  const Duration(seconds: 5),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: _loading
                                        ? const CircularProgressIndicator()
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontFamily: 'OpenSans',
                                            ),
                                          ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _forgotPassword,
                                  child: const Text('Forgot Password'),
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final rememberMe = _rememberMe;

        await FirebaseAuth.instance.signOut();

        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        setState(() {
          _loginAttempts = 0;
          _lockedUntil = null;
          _loading = false;
        });

        final DocumentReference userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.email);

        if (_lockedUntil != null && _lockedUntil!.isAfter(DateTime.now())) {
          final remainingSeconds =
              _lockedUntil!.difference(DateTime.now()).inSeconds;
          _showError(
              'Your account has been locked. Please try again in $remainingSeconds minutes.');
        }

        await _saveCredentials(email, password);

        // Save session ID to Firestore
        final sessionID = const Uuid().v4();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          'session_id': sessionID,
        });
        // Save session ID to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', sessionID);

        // Navigate to home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => Homepage(
                    email: email,
                  )),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          _loginAttempts++;
          if (_loginAttempts >= 3) {
            _lockedUntil = DateTime.now().add(const Duration(minutes: 2));
            _showError(
                'Your account has been locked for 2 minutes due to multiple failed login attempts.');
          } else {
            _showError(
                'Invalid email or password. You have attempted $_loginAttempts out of 3 attempts remaining.');
          }
        }
      } catch (e) {
        _showError('An error occurred while logging in.');
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _checkSession() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();

      if (snapshot.exists) {
        final currentSessionID = snapshot.get('session_id');
        final storedSessionID = prefs.getString('session_id');

        if (storedSessionID == currentSessionID) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => Homepage(
                email: user.email!,
              ),
            ),
          );
        } else {
          await FirebaseAuth.instance.signOut().then((value) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
            _showError('You have been logged out from another device/browser.');
          });
          await prefs.remove('session_id');
        }
      }
    }
  }
}
