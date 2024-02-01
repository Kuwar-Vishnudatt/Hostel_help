// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hostel_help/pages/complaint/discipline_page.dart';
import 'package:hostel_help/pages/main_screen.dart';
import '../../auth_helper.dart';
import '../complaint/general_page.dart';
import '../complaint/lan_page.dart';
import '../complaint/power_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

// import 'dart:io';
import '../complaint/water_page.dart';
import 'user_complaint_page.dart';

import 'package:carousel_slider/carousel_slider.dart';

MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

void main() {
  runApp(UserHomePage());
}

class UserHomePage extends StatefulWidget {
  UserHomePage({Key? key}) : super(key: key);

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final _auth = FirebaseAuth.instance;

  final _firestore = FirebaseFirestore.instance;
  DateTime? prevTime;
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
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

  void _logout(BuildContext context) async {
    await _auth.signOut();
    await AuthHelper.setIsLoggedIn(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HostelHelp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = kToolbarHeight;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: createMaterialColor(Color.fromARGB(255, 255, 255, 255)),
      ),
      home: SafeArea(
        child: Scaffold(
          extendBody: true,
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(appBarHeight),
            child: Container(
              color: Colors.black,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _logout(context),
                  ),
                  Text(
                    'HOSTEL HELP',
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle),
                    onPressed: () async {
                      final user = _auth.currentUser;
                      if (user != null) {
                        final userData = await _firestore
                            .collection('users')
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
                                    Text('Roll: ${userData['roll']}'),
                                    Text('Hostel: ${userData['hostelNumber']}'),
                                    Text(
                                        'Room Number: ${userData['roomNumber']}'),
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
                                            const UserComplaintsPage(),
                                      ),
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
            ),
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Center(
                child: IconSlider(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IconSlider extends StatefulWidget {
  const IconSlider({Key? key}) : super(key: key);

  @override
  _IconSliderState createState() => _IconSliderState();
}

class _IconSliderState extends State<IconSlider> {
  int _current = 0;
  bool _showPower = true;
  bool _showLan = false;
  bool _showGeneral = false;
  bool _showDiscipline = false;
  bool _showWater = false;

  final List<String> imgList = [
    'assets/images/power_icon.jpg',
    'assets/images/lan_icon.jpg',
    'assets/images/bathroom_icon.jpg',
    'assets/images/discipline_icon.jpg',
    'assets/images/water_icon.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        CarouselSlider(
          options: CarouselOptions(
            height: 400,
            aspectRatio: 16 / 9,
            viewportFraction: 0.5,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: false,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              HapticFeedback.heavyImpact();
              setState(() {
                _current = index;
                _showPower = index == 0;
                _showLan = index == 1;
                _showGeneral = index == 2;
                _showDiscipline = index == 3;
                _showWater = index == 4;
              });
            },
          ),
          items: imgList.map((item) {
            int index = imgList.indexOf(item);
            String label;
            switch (index) {
              case 0:
                label = 'POWER';
                break;
              case 1:
                label = 'LAN';
                break;
              case 2:
                label = 'GENERAL';
                break;
              case 3:
                label = 'DISCIPLINARY ACTION';
                break;
              case 4:
                label = 'WATER';
                break;
              default:
                label = '';
            }
            return Column(
              children: [
                Container(
                  child: Center(
                    child: ClipOval(
                      child: Image.asset(item, fit: BoxFit.cover, width: 1000),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 2.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromARGB(255, 255, 255, 255)
                        : Color.fromARGB(255, 104, 103, 103),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(
              parent: _showPower ||
                      _showLan ||
                      _showGeneral ||
                      _showDiscipline ||
                      _showWater
                  ? const AlwaysStoppedAnimation(1)
                  : const AlwaysStoppedAnimation(0),
              curve: Curves.easeInOut,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: _showPower ||
                    _showLan ||
                    _showGeneral ||
                    _showDiscipline ||
                    _showWater
                ? MediaQuery.of(context).size.height
                : 0,
            child: _showPower
                ? PowerComplaintPage()
                : _showLan
                    ? LanComplaintPage()
                    : _showGeneral
                        ? GeneralComplaintPage()
                        : _showDiscipline
                            ? DisciplineComplaintPage()
                            : _showWater
                                ? WaterComplaintPage()
                                : Container(),
          ),
        ),
      ],
    );
  }
}
