// ignore_for_file: use_build_context_synchronously, unused_local_variable, library_private_types_in_public_api, unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // create a global key for the form
  final _formKey = GlobalKey<FormState>();

  // create text editing controllers for the input fields
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _hostelNumberController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // create a variable to store the auth status
  String _authStatus = "";

  // create a method to validate and save the form
  void _saveForm() async {
    // get the current state of the form
    final form = _formKey.currentState;

    // check if the form is valid
    if (form!.validate()) {
      // save the form fields
      form.save();

      // get the input values
      final name = _nameController.text;
      final rollNumber = _rollNumberController.text;
      final hostelNumber = _hostelNumberController.text;
      final roomNumber = _roomNumberController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      // sign in the user with email and password
      _signIn(email, password);
    }
  }

  // create a method to sign in the user with email and password
  void _signIn(String email, String password) async {
    // get the firebase auth instance
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      // sign in the user with email and password
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // get the current user
      User? user = auth.currentUser;

      // show a message
      setState(() {
        _authStatus = "Login successful. Welcome ${user!.displayName}";
      });

      // navigate to the home page and remove the login page
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // show a message
      setState(() {
        _authStatus = "Login failed: ${e.message}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    hintText: "Enter your name",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your name";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _nameController.text = value!;
                  },
                ),
                TextFormField(
                  controller: _rollNumberController,
                  decoration: const InputDecoration(
                    labelText: "Roll Number",
                    hintText: "Enter your roll number",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your roll number";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _rollNumberController.text = value!;
                  },
                ),
                TextFormField(
                  controller: _hostelNumberController,
                  decoration: const InputDecoration(
                    labelText: "Hostel Number",
                    hintText: "Enter your hostel number",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your hostel number";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _hostelNumberController.text = value!;
                  },
                ),
                TextFormField(
                  controller: _roomNumberController,
                  decoration: const InputDecoration(
                    labelText: "Room Number",
                    hintText: "Enter your room number",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your room number";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _roomNumberController.text = value!;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your email",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your email";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _emailController.text = value!;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your password";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _passwordController.text = value!;
                  },
                ),
                const SizedBox(height: 16), // a vertical space of 16 pixels
                ElevatedButton(
                  onPressed: _saveForm, // the logic of the button
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // the color of the button
                  ),
                  child: const Text("Login"),
                ),
                const SizedBox(height: 16), // a vertical space of 16 pixels
                Text(_authStatus), // the text to display the auth status
              ],
            ),
          ),
        ),
      ),
    );
  }
}
