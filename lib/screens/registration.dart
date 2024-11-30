import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pexllite/constants.dart';
import 'otp.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  // Defining a Form Key
  final _formKey = GlobalKey<FormState>();

  // Defining Editing Controllers
  final TextEditingController firstNameEditingController = TextEditingController();
  final TextEditingController lastNameEditingController = TextEditingController();
  final TextEditingController phoneNumberEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // First Name Field
    final firstNameField = TextFormField(
      autofocus: false,
      controller: firstNameEditingController,
      keyboardType: TextInputType.text,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("First Name is required!");
        }
        if (!regex.hasMatch(value)) {
          return ("Name must be min. 3 characters long");
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.account_circle_outlined),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: "First Name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Last Name Field
    final lastNameField = TextFormField(
      autofocus: false,
      controller: lastNameEditingController,
      keyboardType: TextInputType.text,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Last Name is required!");
        }
        if (!regex.hasMatch(value)) {
          return ("Name must be min. 3 characters long");
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.account_circle_outlined),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: "Last Name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Phone Number Field
    final phoneNumberField = TextFormField(
      autofocus: false,
      controller: phoneNumberEditingController,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter your phone number.");
        }
        if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
          return ("Please enter a valid 10-digit phone number");
        }
        return null;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.phone),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        labelText: "Phone Number",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Register Button
    final registerButton = Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      color: primary,
      child: MaterialButton(
        onPressed: () {
          signUp(
            firstNameEditingController.text,
            lastNameEditingController.text,
            phoneNumberEditingController.text,
          );
        },
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        textColor: Colors.white,
        child: const Text(
          "Get OTP",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Register", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 200,
                    child: Image(
                      image: AssetImage("assets/images/logo.png"),
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 35),
                  firstNameField,
                  const SizedBox(height: 15),
                  lastNameField,
                  const SizedBox(height: 15),
                  phoneNumberField,
                  const SizedBox(height: 30),
                  registerButton,
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String firstName, String lastName, String phoneNumber) async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('$baseurl/user/signup'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "phoneNumber": phoneNumber,
            "firstName": firstName,
            "lastName": lastName,
          }),
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "OTP sent successfully!");

          // Navigate to OTPScreen and pass the phone number
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(phoneNumber: phoneNumber),
            ),
          );
        } else {
          // Handle error response
          final errorMessage =
              jsonDecode(response.body)['message'] ?? 'Failed to send OTP';
          Fluttertoast.showToast(msg: errorMessage);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e");
      }
    }
  }
}
