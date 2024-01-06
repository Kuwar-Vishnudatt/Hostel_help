import 'package:flutter/material.dart';

import 'faculty/faculty_login_page.dart';
import 'faculty/faculty_signup_page.dart';
import 'user/user_login_page.dart';
import 'user/user_signup_page.dart';

void main() {
  runApp(const HostelHelpApp());
}

class HostelHelpApp extends StatelessWidget {
  const HostelHelpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostel Help',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        '/userSignup': (context) => const UserSignupPage(),
        '/facultySignup': (context) => const FacultySignupPage(),
        '/userLogin': (context) => const UserLoginPage(),
        '/facultyLogin': (context) => const FacultyLoginPage(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Hostel Help',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              child: const Text('User Signup'),
              onPressed: () {
                Navigator.pushNamed(context, '/usersignup');
              },
            ),
            ElevatedButton(
              child: const Text('Faculty Signup'),
              onPressed: () {
                Navigator.pushNamed(context, '/facultysignup');
              },
            ),
            ElevatedButton(
              child: const Text('User Login'),
              onPressed: () {
                Navigator.pushNamed(context, '/userlogin');
              },
            ),
            ElevatedButton(
              child: const Text('Faculty Login'),
              onPressed: () {
                Navigator.pushNamed(context, '/facultylogin');
              },
            ),
          ],
        ),
      ),
    );
  }
}
