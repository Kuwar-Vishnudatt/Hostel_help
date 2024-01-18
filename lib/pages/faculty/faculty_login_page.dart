// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hostel_help/pages/faculty/faculty_home_page.dart';

import '../../auth_helper.dart';

class FacultyLoginPage extends StatefulWidget {
  const FacultyLoginPage({Key? key});

  @override
  _FacultyLoginPageState createState() => _FacultyLoginPageState();
}

class _FacultyLoginPageState extends State<FacultyLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool _obscurePassword = true;

  String _errorMessage = ''; // Add this variable to store the error message

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Set isLoggedIn to true
        await AuthHelper.setIsLoggedIn(true);
        await AuthHelper.setUserType('faculty');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FacultyHomePage()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = 'Wrong email or password';
        } else {
          errorMessage = 'Firebase Authentication Error: ${e.message}';
        }
        setState(() {
          _errorMessage = errorMessage;
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      } on FirebaseAuthException catch (e) {
        print(e.message);
      }
    }
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: const Text(
            'Faculty Login',
            style: TextStyle(
              color: Colors.white, // Set text color to white
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                    height:
                        20.0), // Add space between the app bar and text fields
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSaved: (value) => email = value!,
                ),
                SizedBox(
                    height:
                        10.0), // Add space between the email and password fields
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  onSaved: (value) => password = value!,
                ),
                SizedBox(
                    height:
                        20.0), // Add space between the password field and the login button
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 27, 27, 27), // Dark grey color
                  ),
                  child: const Text('Login',
                      style: TextStyle(color: Colors.white)),
                ),
                SizedBox(
                    height:
                        10.0), // Add space between the login button and the forgot password button
                TextButton(
                  onPressed: _resetPassword,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent, // No background color
                    foregroundColor: Colors.white, // White color
                  ),
                  child: const Text('Forgot Password?'),
                ),
                // Display error message if exists
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 17, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
