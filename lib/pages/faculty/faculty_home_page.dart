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
  const FacultyHomePage({Key? key}) : super(key: key);

  @override
  _FacultyHomePageState createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? facultyType;
  String? staffType;
  late String facultyHostelNumber;
  late String staffHostelNumber;
  DateTime? prevTime;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    fetchFacultyType();
    fetchStaffDetails();
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
      SystemNavigator.pop();
      stopDefaultButtonEvent = false;
    }

    return stopDefaultButtonEvent;
  }

  Future<void> fetchFacultyType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userData = await FirebaseFirestore.instance
            .collection('faculty')
            .doc(user.uid)
            .get();
        setState(() {
          facultyType = userData['facultyType'];
          if (facultyType == 'Warden') {
            // Fetch facultyHostelNumber only for Wardens
            facultyHostelNumber = userData['hostelNumber'];
          }
        });
      } catch (e) {
        print("Error fetching facultyType: $e");
        // Handle error
      }
    }
  }

  Future<void> fetchStaffDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final staffData = await FirebaseFirestore.instance
            .collection('staff')
            .doc(user.uid)
            .get();
        setState(() {
          staffType = staffData['staffType'];
          if (staffType == 'Hostel Incharge') {
            // Fetch facultyHostelNumber only for Wardens
            staffHostelNumber = staffData['hostelNumber'];
          }
        });
      } catch (e) {
        print("Error fetching staffType: $e");
        // Handle error
      }
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

  void _buildProfileDialog(BuildContext context, String name, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Name: $name'),
                Text('Type: $type'),
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

  @override
  Widget build(BuildContext context) {
    if (facultyType == null && staffType == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Faculty Home Page'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black, // Set the background color to black
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
            Text(
              'Faculty Home Page',
              style: TextStyle(
                color: Colors.white, // Set the title text color to white
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () async {
                final user = _auth.currentUser;
                if (user != null) {
                  String profileName = 'Unknown';
                  String profileType = 'Unknown';

                  if (facultyType != null) {
                    final userData = await _firestore
                        .collection('faculty')
                        .doc(user.uid)
                        .get();
                    profileName = userData['name'];
                    profileType = userData['facultyType'];
                  } else if (staffType != null) {
                    final staffData = await _firestore
                        .collection('staff')
                        .doc(user.uid)
                        .get();
                    profileName = staffData['name'];
                    profileType = staffData['staffType'];
                  }

                  _buildProfileDialog(context, profileName, profileType);
                }
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('complaints')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> complaints =
              snapshot.data!.docs.where((complaint) {
            String complaintType = complaint['type'];

            if (facultyType == 'Chiefwarden' &&
                (complaintType == 'Discipline' || complaintType == 'General')) {
              return true;
            } else if (facultyType == 'Warden' &&
                complaintType == 'General' &&
                facultyHostelNumber == complaint['hostelNumber']) {
              return true;
            } else if ((facultyType == 'LAN' ||
                    facultyType == 'Power' ||
                    facultyType == 'Water') &&
                facultyType == complaintType) {
              return true;
            } else if ((staffType == 'Power' ||
                    staffType == 'LAN' ||
                    staffType == 'General' ||
                    staffType == 'Water') &&
                staffType == complaintType) {
              return true;
            } else if (staffType == 'Hostel Incharge') {
              if (staffHostelNumber.isNotEmpty &&
                  staffHostelNumber == complaint['hostelNumber']) {
                return true;
              }
            }
            return false;
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
                title: Text(
                  'Complaint: ${complaint['complaint']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Complaint from ${complaint['name']}\n',
                      ),
                      TextSpan(
                        text: 'Roll: ${complaint['roll']}\n'
                            'Hostel Number: ${complaint['hostelNumber']}\n'
                            'Room Number: ${complaint['roomNumber']}\n'
                            'Phone Number: ${complaint['phoneNumber']}\n'
                            'date: ${_formatTimestamp(complaint['date'])}\n'
                            'Addressed: ',
                      ),
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
      DateTime dateTime = DateTime.parse(timestamp);
      String formattedDate =
          '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
      return ': $formattedDate';
    } else {
      return ': No timestamp';
    }
  }
}
