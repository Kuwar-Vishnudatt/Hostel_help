// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultyHomePage extends StatefulWidget {
  const FacultyHomePage({super.key});

  @override
  _FacultyHomePageState createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/facultylogin');
  }

  void _markAsSeen(DocumentSnapshot complaint) async {
    await _firestore
        .collection('complaints')
        .doc(complaint.id)
        .update({'seen': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Faculty Home Page'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('complaints').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot complaint = snapshot.data!.docs[index];
              bool seen =
                  (complaint.data() as Map<String, dynamic>).containsKey('seen')
                      ? complaint['seen']
                      : false;
              bool addressed = (complaint.data() as Map<String, dynamic>)
                      .containsKey('addressed')
                  ? complaint['addressed']
                  : false;
              return ListTile(
                title: Text('Complaint from ${complaint['name']}'),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Roll: ${complaint['roll']}\n'
                              'Hostel Number: ${complaint['hostelNumber']}\n'
                              'Room Number: ${complaint['roomNumber']}\n'
                              'Phone Number: ${complaint['phoneNumber']}\n'
                              'Complaint: ${complaint['complaint']}\n'
                              'Addressed: '),
                      TextSpan(
                        text: '${addressed ? 'Yes' : 'No'}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: addressed ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                      seen ? Icons.check_box : Icons.check_box_outline_blank),
                  onPressed: () => _markAsSeen(complaint),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
