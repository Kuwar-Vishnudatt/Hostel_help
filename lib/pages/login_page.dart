import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // create a global key for the form
  final _formKey = GlobalKey<FormState>();

  // create text editing controllers for the input fields
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _hostelNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // create a variable to store the verification id
  late String _verificationId;

  // create a variable to store the auth status
  String _authStatus = "";

  // create a method to validate and save the form
  void _saveForm() async {
    // get the current state of the form
    final form = _formKey.currentState;

    // check if the form is valid
    if (form!.validate()) {
      // save the form fields
      form.save();

      // get the input values
      final name = _nameController.text;
      final rollNumber = _rollNumberController.text;
      final roomNumber = _roomNumberController.text;
      final hostelNumber = _hostelNumberController.text;
      final phoneNumber = _phoneNumberController.text;

      // save the input values to the shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("name", name);
      prefs.setString("rollNumber", rollNumber);
      prefs.setString("roomNumber", roomNumber);
      prefs.setString("hostelNumber", hostelNumber);

      // verify the phone number and send the OTP
      _verifyPhoneNumber(phoneNumber);
    }
  }

  // create a method to verify the phone number and send the OTP
  void _verifyPhoneNumber(String phoneNumber) async {
    // get the firebase auth instance
    FirebaseAuth auth = FirebaseAuth.instance;

    // set the timeout duration
    timeout(String verId) {
      // set the verification id
      _verificationId = verId;

      // show a message
      setState(() {
        _authStatus = "Verification timeout, please try again.";
      });
    }

    // set the verification completed callback
    verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
      // sign in with the credential
      await auth.signInWithCredential(phoneAuthCredential);

      // show a message
      setState(() {
        _authStatus = "Login successful.";
      });
    }

    // set the verification failed callback
    verificationFailed(FirebaseAuthException exception) {
      // show a message
      setState(() {
        _authStatus = "Verification failed: ${exception.message}";
      });
    }

    // set the code sent callback
    codeSent(String verId, [int? forceCodeResend]) {
      // set the verification id
      _verificationId = verId;

      // show a message
      setState(() {
        _authStatus = "Please enter the OTP sent to your phone.";
      });

      // show a dialog to enter the OTP
      _showOTPDialog();
    }

    // set the code auto-retrieval timeout callback
    codeAutoRetrievalTimeout(String verId) {
      // set the verification id
      _verificationId = verId;
    }

    // start the phone number verification process
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // create a method to show a dialog to enter the OTP
  void _showOTPDialog() {
    // create a text editing controller for the OTP field
    final otpController = TextEditingController();

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter OTP"),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "6-digit OTP",
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                // dismiss the dialog
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Verify"),
              onPressed: () {
                // get the OTP value
                final otp = otpController.text.trim();

                // verify the OTP
                _verifyOTP(otp);

                // dismiss the dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // create a method to verify the OTP
  void _verifyOTP(String otp) async {
    // get the firebase auth instance
    FirebaseAuth auth = FirebaseAuth.instance;

    // create a phone auth credential with the OTP and the verification id
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: otp,
    );

    try {
      // sign in with the credential
      await auth.signInWithCredential(credential);

      // show a message
      setState(() {
        _authStatus = "Login successful.";
      });
    } on FirebaseAuthException catch (e) {
      // show a message
      setState(() {
        _authStatus = "Login failed: ${e.message}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
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
                ElevatedButton(
                  onPressed: _saveForm, // the logic of the button
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // the color of the button
                  ),
                  child: const Text("Login"),
                ),
                const SizedBox(height: 16), // a vertical space of 16 pixels
                Text(_authStatus), // the text to display the auth status
              ],
            ),
          ),
        ),
      ),
    );
  }
}
