// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PowerComplaintPage extends StatefulWidget {
  const PowerComplaintPage({super.key});

  @override
  _PowerComplaintPageState createState() => _PowerComplaintPageState();
}

class _PowerComplaintPageState extends State<PowerComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String name;
  late String roll;
  late String hostelNumber;
  late String roomNumber;
  late String phoneNumber;
  late String complaint;

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
        title: const Text('Power Complaint Page'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                // Add your input fields here
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Roll',
                  ),
                  onChanged: (value) {
                    roll = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Hostel Number',
                  ),
                  onChanged: (value) {
                    hostelNumber = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Room Number',
                  ),
                  onChanged: (value) {
                    roomNumber = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Complaint',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: (value) {
                    complaint = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a Snackbar and send the complaint to the other frontend
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')));
                      // Send the complaint to the other frontend
                      final user = _auth.currentUser;
                      if (user != null) {
                        final complaints = await _firestore
                            .collection('complaints')
                            .where('userId', isEqualTo: user.uid)
                            .where('date',
                                isEqualTo: DateTime.now().toIso8601String())
                            .get();
                        if (complaints.docs.isEmpty) {
                          await _firestore.collection('complaints').add({
                            'userId': user.uid,
                            'name': name,
                            'roll': roll,
                            'hostelNumber': hostelNumber,
                            'roomNumber': roomNumber,
                            'phoneNumber': phoneNumber,
                            'complaint': complaint,
                            'seen': false,
                            'date': DateTime.now().toIso8601String(),
                          });
                          print('Complaint submitted successfully.');
                        } else {
                          print(
                              'You have already submitted a complaint today.');
                        }
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
