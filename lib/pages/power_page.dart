// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class PowerComplaintPage extends StatefulWidget {
  const PowerComplaintPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PowerComplaintPageState createState() => _PowerComplaintPageState();
}

class _PowerComplaintPageState extends State<PowerComplaintPage> {
  // create a global key for the form
  final _formKey = GlobalKey<FormState>();

  // create text editing controllers for the input fields
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _hostelNumberController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // create a text editing controller for the complaint field
  final _complaintController = TextEditingController();

  // create a method to validate and submit the form
  void _submitForm() {
    // get the current state of the form
    final form = _formKey.currentState;

    // check if the form is valid
    if (form!.validate()) {
      // save the form fields
      form.save();

      // get the input values
      final name = _nameController.text;
      final rollNumber = _rollNumberController.text;
      final hostelNumber = _hostelNumberController.text;
      final roomNumber = _roomNumberController.text;
      final phoneNumber = _phoneNumberController.text;
      final complaint = _complaintController.text;

      // print the input values for debugging purposes
      print("Name: $name");
      print("Roll Number: $rollNumber");
      print("Hostel Number: $hostelNumber");
      print("Room Number: $roomNumber");
      print("Phone Number: $phoneNumber");
      print("Complaint: $complaint");

      // clear the input fields
      _nameController.clear();
      _rollNumberController.clear();
      _hostelNumberController.clear();
      _roomNumberController.clear();
      _phoneNumberController.clear();
      _complaintController.clear();

      // show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your complaint has been submitted."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Power Complaint Page"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    hintText: "Enter your name",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your name";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _nameController.text = value!;
                  },
                ),
                TextFormField(
                  controller: _rollNumberController,
                  decoration: const InputDecoration(
                    labelText: "Roll Number",
                    hintText: "Enter your roll number",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your roll number";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _rollNumberController.text = value!;
                  },
                ),
                TextFormField(
                  controller: _hostelNumberController,
                  decoration: const InputDecoration(
                    labelText: "Hostel Number",
                    hintText: "Enter your hostel number",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your hostel number";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _hostelNumberController.text = value!;
                  },
                ),
                TextFormField(
                  controller: _roomNumberController,
                  decoration: const InputDecoration(
                    labelText: "Room Number",
                    hintText: "Enter your room number",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your room number";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _roomNumberController.text = value!;
                  },
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    hintText: "Enter your phone number",
                  ),
                  validator: (value) {
                    // check if the value is empty
                    if (value!.isEmpty) {
                      // return an error message
                      return "Please enter your phone number";
                    }
                    // return null if the value is valid
                    return null;
                  },
                  onSaved: (value) {
                    // save the value to the controller
                    _phoneNumberController.text = value!;
                  },
                ),
                const SizedBox(height: 16), // a vertical space of 16 pixels
                TextField(
                  controller: _complaintController,
                  maxLines:
                      5, // the maximum number of lines for the complaint field
                  decoration: const InputDecoration(
                    labelText: "Complaint",
                    hintText: "Enter your complaint",
                    border:
                        OutlineInputBorder(), // a border around the complaint field
                  ),
                ),
                const SizedBox(height: 16), // a vertical space of 16 pixels
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue), // the color of the button
                  onPressed: _submitForm,
                  child: const Text("Submit"), // the logic of the button
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
