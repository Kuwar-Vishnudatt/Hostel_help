// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_home_page.dart';

void main() {
  runApp(const MaterialApp(
    home: UserLoginPage(),
  ));
}

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  bool _obscureText = true;
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;

  void _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Provide feedback to the user that a password reset email has been sent
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'User Login',
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                      color: Colors.white), // Set label color to white
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Set border color to white
                    borderRadius:
                        BorderRadius.circular(10.0), // Set border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Colors.white), // Set focused border color to white
                    borderRadius: BorderRadius.circular(
                        10.0), // Set focused border radius
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
              ),
              SizedBox(height: 10.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white, // Set icon color to white
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  labelStyle: TextStyle(
                      color: Colors.white), // Set label color to white
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Set border color to white
                    borderRadius:
                        BorderRadius.circular(10.0), // Set border radius
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Colors.white), // Set focused border color to white
                    borderRadius: BorderRadius.circular(
                        10.0), // Set focused border radius
                  ),
                ),
                obscureText: _obscureText,
                onChanged: (value) {
                  password = value;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
                      // Navigate to the next screen
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserHomePage()),
                      );
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromARGB(255, 27, 27, 27), // Dark grey color
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: _resetPassword,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent, // No background color
                  foregroundColor: Colors.white, // White color
                ),
                child: const Text(
                  'Forgot Password?',
                ),
              ),
              // TextButton(
              //   onPressed: () =>
              //       Navigator.pushReplacementNamed(context, '/usersignup'),
              //   child: const Text("Don't have an account? Signup"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
