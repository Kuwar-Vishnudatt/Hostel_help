import 'package:flutter/material.dart';
import 'package:hostel_help/pages/faculty/faculty_home_page.dart';
import 'package:hostel_help/pages/faculty/faculty_login_page.dart';
// import 'package:hostel_help/pages/faculty/faculty_signup_page.dart';
import 'package:hostel_help/pages/user/user_login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hostel_help/pages/user/user_signup_page.dart';
import 'package:hostel_help/pages/splash_screen.dart';

import 'pages/user/user_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashScreen(),
      '/userlogin': (context) => const UserLoginPage(),
      '/userhome': (context) => const UserHomePage(),
      '/facultyhome': (context) => const FacultyHomePage(),
      '/usersignup': (context) => const UserSignupPage(),
      // '/facultysignup': (context) => const FacultySignupPage(),
      '/facultylogin': (context) => const FacultyLoginPage(),
    },
  ));
}
