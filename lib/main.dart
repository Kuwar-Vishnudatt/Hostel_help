import 'package:flutter/material.dart';
import 'package:hostel_help/pages/faculty/faculty_home_page.dart';
import 'package:hostel_help/pages/faculty/faculty_login_page.dart';
// import 'package:hostel_help/pages/faculty/faculty_signup_page.dart';
import 'package:hostel_help/pages/user/user_login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hostel_help/pages/user/user_signup_page.dart';
import 'package:hostel_help/pages/main_screen.dart';

import 'pages/user/user_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(255, 0, 0, 0),
        scaffoldBackgroundColor: Colors.black),
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case '/':
          return MaterialPageRoute(builder: (context) => const HostelHelp());
        case '/userhome':
          return MaterialPageRoute(builder: (context) => UserHomePage());
        case '/facultyhome':
          return MaterialPageRoute(
              builder: (context) => const FacultyHomePage());
        default:
          return MaterialPageRoute(builder: (context) => NotFoundPage());
      }
    },
  ));
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Text('404 - Page Not Found'),
      ),
    );
  }
}
