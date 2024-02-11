// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final timestamp = DateTime.now().toIso8601String();
  String type = 'Power';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Power Complaint Page',
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
                    await submitComplaint(phoneNumber, complaint, type);
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

  Future<void> submitComplaint(
      String phoneNumber, String complaint, String type) async {
    final complaintsCollection =
        FirebaseFirestore.instance.collection('complaints');
    final user = FirebaseAuth.instance.currentUser;
    final todayDate = DateTime.now();
    final timestamp = DateTime(todayDate.year, todayDate.month, todayDate.day)
        .toIso8601String();

    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final name = userData['name'];
      final roll = userData['roll'];
      final hostelNumber = userData['hostelNumber'];
      final roomNumber = userData['roomNumber'];

      final complaints = await complaintsCollection
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: timestamp)
          .where('type', isEqualTo: type)
          .get();

      if (complaints.docs.isEmpty) {
        final complaintRef = await complaintsCollection.add({
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

        // Send a notification to the faculty responsible for this type of complaint
        String powerFacultyFcmToken = 'fcm_token_here';
        await sendNotificationToFaculty(powerFacultyFcmToken,
            'New Power Complaint', 'A new power complaint has been submitted.');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint registered')),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already submitted a complaint today')),
        );
        _formKey.currentState!.reset();
      }
    }
  }

  Future<void> sendNotificationToFaculty(
      String fcmToken, String title, String body) async {
    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA0rx9LIw:APA91bGvbNK-V6762-Jvad_77XbXuobyAo1P9vTQBkExQ-wSaIbvcXcyu_Ce8yHYUHdNvxN6uuPqtXTKIztwkyRvWzHQlP6GM4-RElEzlvtT3xlDuBQ6_w0luab3pF5__CjUa68Pbki_',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to': fcmToken,
          },
        ),
      );
      if (response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print('Error sending notification: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }
}
