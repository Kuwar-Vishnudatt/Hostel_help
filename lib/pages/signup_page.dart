// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String name;
  late String roll;
  late String hostelNumber;
  late String roomNumber;
  late String email;
  late String password;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        User? user = userCredential.user;
        await _firestore.collection('users').doc(user!.uid).set({
          'name': name,
          'roll': roll,
          'hostelNumber': hostelNumber,
          'roomNumber': roomNumber,
        });
        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Page'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              onSaved: (value) => name = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Roll'),
              onSaved: (value) => roll = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Hostel Number'),
              onSaved: (value) => hostelNumber = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Room Number'),
              onSaved: (value) => roomNumber = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              onSaved: (value) => email = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onSaved: (value) => password = value!,
            ),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('Signup'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
