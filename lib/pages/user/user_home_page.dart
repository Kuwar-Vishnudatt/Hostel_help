// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../complaint/power_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_complaint_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  void _navigateToPowerPage() {
    // use the Navigator.push method to push a new route
    Navigator.push(
      context,
      // use the MaterialPageRoute class to create a route
      MaterialPageRoute(
        // use the PowerComplaintPage class as the builder of the route
        builder: (context) => const PowerComplaintPage(),
      ),
    );
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/userlogin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(248, 255, 255, 255),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Hostel Complaint Service'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () async {
                final user = _auth.currentUser;
                if (user != null) {
                  final userData =
                      await _firestore.collection('users').doc(user.uid).get();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Profile'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Name: ${userData['name']}'),
                              Text('Roll: ${userData['roll']}'),
                              Text('Hostel: ${userData['hostelNumber']}'),
                              Text('Room Number: ${userData['roomNumber']}'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('View Complaints'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const UserComplaintsPage()),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "POWER",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 119, 207, 246),
                      fontSize: 30),
                ),
                IconButton(
                  icon: Image.asset('assets/power_icon.jpg'),
                  iconSize: 200,
                  onPressed: () {
                    _navigateToPowerPage(); // Handle power icon press
                  },
                ),
                const Text(
                  "LAN",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 119, 207, 248),
                      fontSize: 30),
                ),
                IconButton(
                  icon: Image.asset('assets/lan_icon.jpg'),
                  iconSize: 200,
                  onPressed: () {
                    // Handle LAN icon press
                  },
                ),
                const Text(
                  "GENERAL",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 119, 207, 246),
                      fontSize: 30),
                ),
                IconButton(
                  icon: Image.asset('assets/bathroom_icon.jpg'),
                  iconSize: 200,
                  onPressed: () {
                    // Handle bathroom icon press
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
