// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaterComplaintPage extends StatefulWidget {
  const WaterComplaintPage({super.key});

  @override
  _WaterComplaintPageState createState() => _WaterComplaintPageState();
}

class _WaterComplaintPageState extends State<WaterComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String name;
  late String roll;
  late String hostelNumber;
  late String roomNumber;
  late String phoneNumber;
  late String complaint;
  final timestamp = DateTime.now().toIso8601String();
  String type = 'Water';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Water Complaint Page',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(212, 255, 255, 255)),
        ),
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
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle:
                        TextStyle(color: Colors.white), // White label color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          12.0), // Adjust the value as needed
                      borderSide:
                          BorderSide(color: Colors.white), // White border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          12.0), // Adjust the value as needed
                      borderSide:
                          BorderSide(color: Colors.white), // White border color
                    ),
                    filled: true,
                    fillColor: Colors.black, // Black background color
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Phone number regex validation
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0), // Add space between fields
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Complaint',
                    labelStyle:
                        TextStyle(color: Colors.white), // White label color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          12.0), // Adjust the value as needed
                      borderSide:
                          BorderSide(color: Colors.white), // White border color
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          12.0), // Adjust the value as needed
                      borderSide:
                          BorderSide(color: Colors.white), // White border color
                    ),
                    filled: true,
                    fillColor: Colors.black, // Black background color
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: (value) {
                    complaint = value;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color.fromARGB(255, 27, 27, 27), // Dark grey color
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a Snackbar and send the complaint to the other frontend
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                      // Send the complaint to the other frontend
                      final user = _auth.currentUser;
                      final todayDate = DateTime.now();
                      final timestamp = DateTime(
                              todayDate.year, todayDate.month, todayDate.day)
                          .toIso8601String();

                      if (user != null) {
                        final userData = await _firestore
                            .collection('users')
                            .doc(user.uid)
                            .get();
                        final name = userData['name'];
                        final roll = userData['roll'];
                        final hostelNumber = userData['hostelNumber'];
                        final roomNumber = userData['roomNumber'];

                        final complaints = await _firestore
                            .collection('complaints')
                            .where('userId', isEqualTo: user.uid)
                            .where('date', isEqualTo: timestamp)
                            .where('type', isEqualTo: type)
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
                            'addressed': false,
                            'date': FieldValue.serverTimestamp(),
                            'type': type,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Complaint registered')),
                          );
                          _formKey.currentState!.reset();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Already submitted a complaint today')),
                          );
                          _formKey.currentState!.reset();
                        }
                      }
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
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
