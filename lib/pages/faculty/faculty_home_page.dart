// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unnecessary_string_interpolations
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../auth_helper.dart';
import '../main_screen.dart';

class FacultyHomePage extends StatefulWidget {
  const FacultyHomePage({super.key});

  @override
  _FacultyHomePageState createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late String facultyType;
  DateTime? prevTime;
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    fetchFacultyType();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  Future<bool> myInterceptor(
      bool stopDefaultButtonEvent, RouteInfo info) async {
    DateTime now = DateTime.now();

    if (prevTime == null || now.difference(prevTime!) > Duration(seconds: 2)) {
      Fluttertoast.showToast(
        msg: 'Press back again to exit the app',
        timeInSecForIosWeb: 2,
      );
      await AuthHelper.setIsLoggedIn(true);
      prevTime = now;
      stopDefaultButtonEvent = true;
    } else {
      await AuthHelper.setIsLoggedIn(true);
      // Use SystemNavigator to exit the app
      SystemNavigator.pop();
      stopDefaultButtonEvent = false;
    }

    return stopDefaultButtonEvent;
  }

  void fetchFacultyType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('faculty')
          .doc(user.uid)
          .get();
      setState(() {
        facultyType = userData['facultyType'];
      });
    }
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
    await AuthHelper.setIsLoggedIn(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HostelHelp()),
    );
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
              icon: const Icon(Icons.account_circle),
              onPressed: () async {
                final user = _auth.currentUser;
                if (user != null) {
                  final userData = await _firestore
                      .collection('faculty')
                      .doc(user.uid)
                      .get();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Profile'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Name: ${userData['name']}'),
                              Text('Type: ${userData['facultyType']}'),
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
                        ],
                      );
                    },
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('complaints')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // ignore: unnecessary_null_comparison
          if (facultyType == null || facultyType.isEmpty) {
            return const Center(child: Text('No faculty type found.'));
          }
          List<DocumentSnapshot> complaints =
              snapshot.data!.docs.where((complaint) {
            String complaintType = complaint['type'];
            return complaintType == facultyType;
          }).toList();
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              DocumentSnapshot complaint = complaints[index];
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
                              'date: ${_formatTimestamp(complaint['date'])}\n'
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

  _formatTimestamp(String timestamp) {
    if (timestamp.isNotEmpty) {
      DateTime dateTime = DateTime.parse(timestamp); // Parse string to DateTime
      String formattedDate =
          '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
      return ': $formattedDate'; // Display the formatted DateTime
    } else {
      return ': No timestamp';
    }
  }
}
