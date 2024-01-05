import 'package:flutter/material.dart';
import 'package:hostel_help/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hostel_help/pages/signup_page.dart';

import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const SignupPage(),
      '/login': (context) => const LoginPage(),
      '/home': (context) => const HomePage(),
    },
  ));
}
