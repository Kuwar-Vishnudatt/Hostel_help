// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unnecessary_string_interpolations
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../auth_helper.dart';
import '../main_screen.dart';

class FacultyHomePage extends StatefulWidget {
  const FacultyHomePage({Key? key}) : super(key: key);

  @override
  _FacultyHomePageState createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
  final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // const IOSInitializationSettings iosInitializationSettings =
    //     IOSInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      // iOS: iosInitializationSettings,
    );
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    fetchFacultyType();
    fetchStaffDetails();
    // Initialize Firebase Cloud Messaging
    _initFirebaseCloudMessaging();
    // Initialize FlutterLocalNotificationsPlugin
    localNotificationsPlugin.initialize(initializationSettings);

    // Handle incoming notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        localNotificationsPlugin.show(
          notification.hashCode,
          notification.title!,
          notification.body!,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'your_channel_id',
              'your_channel_name',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
            ),
          ),
        );
      }
    });
  }

  // Initialize Firebase Cloud Messaging
  void _initFirebaseCloudMessaging() {
    // Request permission for receiving notifications
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure Firebase Cloud Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming messages here
      print('Received notification: ${message.notification?.title}');
    });
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

  TextStyle _getAddressedTextStyle(bool addressed) {
    return TextStyle(
      color: addressed ? Colors.green : Colors.red,
      fontWeight: FontWeight.bold,
    );
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
                    _generatePdf();
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
        labelText:
            'Materials Used for Complaint: ${complaint.complaint['complaint']}',
      ),
    );
  }

  // Function to generate PDF report for selected complaints
  Future<void> _generatePdf() async {
    print('Generating PDF...');
    final pdf = pw.Document();
    final complaints = selectedComplaintsList
        .where((complaint) => complaint.isSelected.value)
        .toList();
// Request the WRITE_EXTERNAL_STORAGE permission on Android
    if (Platform.isAndroid) {
      final permission = Permission.storage;
      if (!(await permission.isGranted)) {
        try {
          await permission.request();
        } catch (e) {
          print('Permission not granted: $e');
        }
      }
    }
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Hostel Management App', style: pw.TextStyle(fontSize: 24)),
            pw.Text('PDF Report', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('Complaint'),
                    pw.Text('Name'),
                    pw.Text('Roll'),
                    pw.Text('Hostel Number'),
                    pw.Text('Room Number'),
                    pw.Text('Phone Number'),
                    pw.Text('Date'),
                    pw.Text('Resolved'),
                    pw.Text('Material Used'),
                  ],
                ),
                ...complaints.map((complaint) {
                  return pw.TableRow(
                    children: [
                      pw.Text(complaint.complaint['complaint'].toString()),
                      pw.Text(complaint.complaint['name'].toString()),
                      pw.Text(complaint.complaint['roll'].toString()),
                      pw.Text(complaint.complaint['hostelNumber'].toString()),
                      pw.Text(complaint.complaint['roomNumber'].toString()),
                      pw.Text(complaint.complaint['phoneNumber'].toString()),
                      pw.Text(_formatTimestamp(
                          complaint.complaint['date'] ?? Timestamp.now())),
                      pw.Text(complaint.complaint['addressed'] ? 'Yes' : 'No'),
                      pw.Text(complaint.materialUsed ?? ''),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        );
      },
    ));

    final directory = await getExternalStorageDirectory();
    final path = directory!.path;
    final Uint8List pdfBytes = await pdf.save();
    final List<int> pdfList = pdfBytes.toList();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(
        '$path/report_$timestamp.pdf'); // Use the correct path for the external storage directory
    await file.writeAsBytes(pdfList);

    Fluttertoast.showToast(msg: 'PDF Report Generated Successfully');
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
            DataColumn(label: Text('Resolved')),
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
                DataCell(
                  Text(
                    addressed ? 'Yes' : 'No',
                    style: _getAddressedTextStyle(addressed),
                  ),
                ),
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
