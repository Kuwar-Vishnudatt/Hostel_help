import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';

// Import your user and faculty login/signup pages here
import 'user/user_login_page.dart';
import 'user/user_signup_page.dart';
import 'faculty/faculty_login_page.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
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
  runApp(const HostelHelp());
}

class HostelHelp extends StatelessWidget {
  const HostelHelp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: createMaterialColor(Color.fromARGB(255, 255, 255, 255)),
      ),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        appBar: AppBar(
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            title: Center(
              child: const Text(
                'HOSTEL HELP',
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold),
              ),
            )),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
            child: IconSlider(),
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
  bool _showLogin = true;
  bool _showSignup = false;
  bool _showFacultyLogin = false;

  final List<String> imgList = [
    'assets/images/login.jpg',
    'assets/images/signup.jpg',
    'assets/images/faculty.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 25,
        ),
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
                _showLogin = index == 0;
                _showSignup = index == 1;
                _showFacultyLogin = index == 2;
              });
            },
          ),
          items: imgList.map((item) {
            int index = imgList.indexOf(item);
            String label;
            switch (index) {
              case 0:
                label = 'Login';
                break;
              case 1:
                label = 'Signup';
                break;
              case 2:
                label = 'Faculty';
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
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 2.0),
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
              parent: _showLogin || _showSignup || _showFacultyLogin
                  ? const AlwaysStoppedAnimation(1)
                  : const AlwaysStoppedAnimation(0),
              curve: Curves.easeInOut,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: _showLogin || _showSignup || _showFacultyLogin
                ? MediaQuery.of(context).size.height
                : 0,
            child: _showLogin
                ? UserLoginPage()
                : _showSignup
                    ? UserSignupPage()
                    : _showFacultyLogin
                        ? FacultyLoginPage()
                        : Container(),
          ),
        ),
      ],
    );
  }
}
