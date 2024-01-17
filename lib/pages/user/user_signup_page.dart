// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_home_page.dart';

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
      } on FirebaseAuthException catch (e) {
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
          'User Signup',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
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
                  onSaved: (value) => name = value!,
                ),
                SizedBox(
                    height: 10.0), // Add space between the name and roll fields
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Roll',
                    labelStyle: TextStyle(color: Colors.white),
                    helperText: "Enter in the format:branch/15xxx/22",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your roll number';
                    }
                    // Regex pattern for roll number
                    String pattern =
                        r'^(btech|BTECH|bba|BBA|mba|MBA|mtech|MTECH|bca|BCA|mca|MCA)/\d{5}/\d{2}$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return 'Invalid roll number format';
                    }
                    return null;
                  },
                  onSaved: (value) => roll = value!,
                ),
                SizedBox(
                    height:
                        10.0), // Add space between the roll and hostel fields
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hostel Number',
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
                SizedBox(
                    height:
                        10.0), // Add space between the hostel and room fields
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Room Number',
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
                  onSaved: (value) => roomNumber = value!,
                ),
                SizedBox(
                    height:
                        10.0), // Add space between the room and email fields
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
                  validator: (value) {
                    if (value == null || !emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
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
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
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
                  obscureText: _obscureText,
                  onSaved: (value) => password = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    if (!RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).*$')
                        .hasMatch(value)) {
                      return 'Password must contain at least one special character and one number';
                    }
                    return null;
                  },
                ),
                SizedBox(
                    height:
                        10.0), // Add space between the password and signup button
                ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 27, 27, 27), // Dark grey color
                  ),
                  child: const Text('Signup',
                      style: TextStyle(color: Colors.white)),
                ),
                // TextButton(
                //   onPressed: () =>
                //       Navigator.pushReplacementNamed(context, '/userlogin'),
                //   child: const Text('Already have an account? Login'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
