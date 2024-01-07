// ignore_for_file: use_build_context_synchronously, avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultySignupPage extends StatefulWidget {
  const FacultySignupPage({Key? key});

  @override
  _FacultySignupPageState createState() => _FacultySignupPageState();
}

class _FacultySignupPageState extends State<FacultySignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String facultyType = 'Power';
  late String name;
  late String email;
  late String password;
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
        await _firestore.collection('faculty').doc(user!.uid).set({
          'facultyType': facultyType,
          'name': name,
          'email': email,
          'seen': false,
          'addressed': false,
        });
        Navigator.pushReplacementNamed(context, '/facultyhome');
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
        title: const Text('Faculty Signup'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Faculty Type',
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: facultyType,
                  onChanged: (String? newValue) {
                    setState(() {
                      facultyType = newValue!;
                    });
                  },
                  items: <String>['Power', 'LAN', 'General']
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
              decoration: const InputDecoration(labelText: 'Name'),
              onSaved: (value) => name = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
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
            ),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('Signup'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/facultylogin'),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
