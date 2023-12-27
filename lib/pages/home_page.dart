import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(248, 255, 255, 255),
        appBar: AppBar(
          title: const Text('Hostel Complaint Service'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "POWER",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 119, 207, 246),
                      fontSize: 30),
                ),
                IconButton(
                  icon: Image.asset('assets/power_icon.jpg'),
                  iconSize: 200,
                  onPressed: () {
                    // Handle power icon press
                  },
                ),
                const Text(
                  "LAN",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 119, 207, 248),
                      fontSize: 30),
                ),
                IconButton(
                  icon: Image.asset('assets/lan_icon.jpg'),
                  iconSize: 200,
                  onPressed: () {
                    // Handle LAN icon press
                  },
                ),
                const Text(
                  "GENERAL",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 119, 207, 246),
                      fontSize: 30),
                ),
                IconButton(
                  icon: Image.asset('assets/bathroom_icon.jpg'),
                  iconSize: 200,
                  onPressed: () {
                    // Handle bathroom icon press
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
