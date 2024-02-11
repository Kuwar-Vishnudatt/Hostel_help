import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hostel_help/pages/faculty/faculty_home_page.dart';
import 'package:hostel_help/pages/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hostel_help/pages/user/user_home_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'auth_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureFirebase();
  FirebaseMessaging.instance.getInitialMessage();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(255, 0, 0, 0),
        scaffoldBackgroundColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        'hostelhelp': (context) => HostelHelp(),
        '/userhome': (context) => UserHomePage(),
        '/facultyhome': (context) => FacultyHomePage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    await Future.delayed(Duration(seconds: 2));

    final isLoggedIn = await AuthHelper.getIsLoggedIn();
    final userType = await AuthHelper.getUserType();

    // Navigate based on the authentication state and user type
    if (isLoggedIn) {
      if (userType == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserHomePage()),
        );
      } else if (userType == 'faculty') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FacultyHomePage()),
        );
      } else {
        // Handle the case where user type is not set
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HostelHelp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(image: AssetImage("assets/images/hostel_help_logo.jpg")),
      ),
    );
  }
}

Future<void> configureFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      // Handle background message when the app is opened from a terminated state
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Handle foreground notifications
    print('Foreground notification: ${message.notification?.title}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle when a notification is opened from the notification center or a tap on the notification
    print('Notification opened: ${message.notification?.title}');
  });

  FirebaseMessaging.instance.requestPermission();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    // Save the FCM token to your database or use it to send notifications
    print('FCM token: $fcmToken');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background notification: ${message.notification?.title}');
  // Handle the background notification here
}
