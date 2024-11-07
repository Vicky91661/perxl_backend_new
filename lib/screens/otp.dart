import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pexllite/constants.dart';
import 'home.dart';
import 'package:pexllite/helpers/helper_functions.dart';

const primary = Color(0xff072227);
const secondary = Color(0xff35858B);
const primaryLight = Color(0xff4FBDBA);
const secondaryLight = Color(0xffAEFEFF);

class OTPScreen extends StatefulWidget {
  final String phoneNumber; // Phone number passed from previous screen

  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // OTP Input Field
    final otpField = TextFormField(
      autofocus: false,
      controller: otpController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter the OTP sent to your phone.");
        }
        if (value.length != 6) {
          return ("Please enter a valid 6-digit OTP.");
        }
        return null;
      },
      onSaved: (value) {
        otpController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.security),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Enter OTP",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Verify Button
    final verifyButton = Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      color: primary,
      child: MaterialButton(
        onPressed: () {
          verifyOtp(widget.phoneNumber, otpController.text);
        },
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        textColor: Colors.white,
        child: const Text(
          "Verify OTP",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          color: primary,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 150,
                      child: Image(
                        image: AssetImage("assets/images/logo.png"),
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 35),
                    Text(
                      "OTP has been sent to ${widget.phoneNumber}",
                      style: const TextStyle(fontSize: 14, color: primary),
                    ),
                    const SizedBox(height: 30),
                    otpField,
                    const SizedBox(height: 30),
                    verifyButton,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to verify OTP
  void verifyOtp(String phoneNumber, String otp) async {
    if (_formKey.currentState!.validate()) {
      // Call your backend API to verify the OTP
      try {
        final response = await http.post(
          Uri.parse('$baseurl/user/verifyotp'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phoneNumber": phoneNumber, "otp": otp}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Assuming `data` contains the user information
          String token = data['token'];
          String currentUserId = data['userId'];
          print("the token and current user id is $token and $currentUserId");

          Fluttertoast.showToast(msg: "OTP Verified Successfully!");
          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserTokenSharedPreference(token);
          await HelperFunctions.saveUserIdSharedPreference(currentUserId);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
          // Save the user Data to the system
        } else {
          final data = jsonDecode(response.body);
          final message = data['message'][0];
          Fluttertoast.showToast(msg: message);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Server not found");
      }
    }
  }
}
