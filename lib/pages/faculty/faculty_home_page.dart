// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unnecessary_string_interpolations
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

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
  Map<DocumentSnapshot, ValueNotifier<bool>> selectedComplaints = {};
  Map<String, String> materialsUsedMap = {};
  List<_ComplaintSelection> selectedComplaintsList = [];

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

  // Function to toggle selection of a complaint
  void _toggleComplaintSelection(DocumentSnapshot complaint) {
    setState(() {
      _ComplaintSelection? existingSelection =
          selectedComplaintsList.firstWhere(
        (selection) => selection.complaint.id == complaint.id,
        orElse: () => _ComplaintSelection(complaint: complaint),
      );

      if (existingSelection.isSelected.value) {
        existingSelection.isSelected.value = false;
        selectedComplaintsList.remove(existingSelection);
      } else {
        existingSelection.isSelected.value = true;
        selectedComplaintsList.add(existingSelection);
      }
    });
  }

  // Function to update materialsUsedMap for selected complaints
  void _updateMaterialsUsedMap() {
    setState(() {
      materialsUsedMap = {};
      for (final selection in selectedComplaintsList) {
        materialsUsedMap[selection.complaint.id] = selection.materialUsed ?? '';
      }
    });
  }

  // Function to show a dialog for materials input
  Future<void> _showMaterialInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Materials Used'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    for (final complaint in selectedComplaintsList)
                      _buildMaterialInputField(complaint, setState),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Generate PDF'),
                  onPressed: () {
                    // Generate PDF with selected complaints and materials used
                    _generatePDFReport();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to build a material input field for each complaint
  Widget _buildMaterialInputField(
      _ComplaintSelection complaint, StateSetter setState) {
    return TextField(
      onChanged: (value) {
        // Update materialsUsedMap when the user enters materials used
        setState(() {
          complaint.materialUsed = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Materials Used for Complaint: }',
      ),
    );
  }

  // Function to generate PDF report for selected complaints
  Future<void> _generatePDFReport() async {
    final pdf = pw.Document();

    for (var complaint in selectedComplaints.keys) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Complaint: ${complaint['complaint']}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Materials Used: ${materialsUsedMap[complaint.id] ?? 'N/A'}'),
              // Add more details as needed
            ],
          ),
        ),
      );
    }

    final output = await getExternalStorageDirectory();
    final file = File("${output?.path}/complaints_report.pdf");
    // Await the result of pdf.save() and use it to write to the file
    final Uint8List pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes);
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

  // Widget to build checkbox for complaint selection
  Widget _buildComplaintCheckbox(DocumentSnapshot complaint) {
    return Checkbox(
      value: selectedComplaints[complaint]?.value ?? false,
      onChanged: (newValue) {
        _toggleComplaintSelection(complaint);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (facultyType == null && staffType == null) {
      return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                ])),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open dialog for materials input and generate PDF
          _updateMaterialsUsedMap();
          _showMaterialInputDialog(context);
        },
        tooltip: 'Generate PDF Report',
        child: Icon(Icons.picture_as_pdf),
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

          List<DataColumn> columns = [
            DataColumn(label: Text('Complaint')),
            DataColumn(label: Text('Complaint from')),
            DataColumn(label: Text('Roll')),
            DataColumn(label: Text('Hostel Number')),
            DataColumn(label: Text('Room Number')),
            DataColumn(label: Text('Phone Number')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Addressed')),
            DataColumn(label: Text('Seen')),
            DataColumn(label: Text('Select')),
          ];

          List<DataRow> rows = snapshot.data!.docs.where((complaint) {
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
              return staffHostelNumber.isNotEmpty &&
                  staffHostelNumber == complaint['hostelNumber'];
            }

            return false;
          }).map((complaint) {
            bool seen =
                (complaint.data() as Map<String, dynamic>).containsKey('seen')
                    ? complaint['seen']
                    : false;
            bool addressed = (complaint.data() as Map<String, dynamic>)
                    .containsKey('addressed')
                ? complaint['addressed']
                : false;
            bool isSelected = selectedComplaintsList
                .any((selection) => selection.complaint.id == complaint.id);

            return DataRow(
              cells: [
                DataCell(Text(complaint['complaint'].toString())),
                DataCell(Text(complaint['name'].toString())),
                DataCell(Text(complaint['roll'].toString())),
                DataCell(Text(complaint['hostelNumber'].toString())),
                DataCell(Text(complaint['roomNumber'].toString())),
                DataCell(Text(complaint['phoneNumber'].toString())),
                DataCell(Text(
                    _formatTimestamp(complaint['date'] ?? Timestamp.now()))),
                DataCell(Text(addressed ? 'Yes' : 'No')),
                DataCell(
                  Checkbox(
                    value: seen,
                    onChanged: (value) {
                      _markAsSeen(complaint);
                    },
                  ),
                ),
                DataCell(
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      _toggleComplaintSelection(complaint);
                    },
                  ),
                ),
              ],
            );
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns,
              rows: rows,
            ),
          );
        },
      ),
    );
  }

  _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate =
        '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
    return ': $formattedDate';
  }
}

class _ComplaintSelection {
  final DocumentSnapshot complaint;
  ValueNotifier<bool> isSelected;
  String? materialUsed;

  _ComplaintSelection({required this.complaint})
      : isSelected = ValueNotifier<bool>(false);
}
