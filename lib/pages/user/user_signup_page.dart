// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSignupPage extends StatefulWidget {
  const UserSignupPage({Key? key});

  @override
  _UserSignupPageState createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String name;
  late String roll;
  String hostelNumber = 'BH3';
  late String roomNumber;
  late String email;
  late String password;
  final RegExp emailRegex = RegExp(
    r"^(btech|BTECH|bba|BBA|mba|MBA|mtech|MTECH|bca|BCA|mca|MCA)\d{5}\.\d{2}@bitmesra\.ac\.in$",
    caseSensitive: false,
  );

  bool _obscureText = true;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        // Send email verification
        await user!.sendEmailVerification();

        // Show a Snackbar to check email and login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email for verification.'),
          ),
        );

// Save user details to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'roll': roll,
          'hostelNumber': hostelNumber,
          'roomNumber': roomNumber,
          // Add other fields as needed
        });

        // Clear the signup page
        _formKey.currentState!.reset();

        // Navigate back to login or home page
        // Replace '/userhome' with the appropriate route
        Navigator.pushReplacementNamed(context, '/userlogin');
      } on FirebaseAuthException catch (e) {
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const BackButtonIcon(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('User Signup Page'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => name = value!,
              ),
              // Other form fields...
              TextFormField(
                decoration: const InputDecoration(labelText: 'Roll'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your roll number';
                  }
                  // Regex pattern for roll number
                  String pattern = r'^(btech|bba|mtech|mba|bca)/\d{5}/\d{2}$';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return 'Invalid roll number format';
                  }
                  return null;
                },
                onSaved: (value) => roll = value!,
              ),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Hostel Number',
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: hostelNumber,
                    onChanged: (String? newValue) {
                      setState(() {
                        hostelNumber = newValue!;
                      });
                    },
                    items: <String>['BH1', 'BH2', 'BH3', 'GH']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Room Number'),
                onSaved: (value) => roomNumber = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || !emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                onSaved: (value) => password = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _signup,
                child: const Text('Signup'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/userlogin'),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
