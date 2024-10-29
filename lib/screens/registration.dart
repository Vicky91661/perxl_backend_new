import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'otp.dart';

// Defining Colors
Color primary = const Color(0xff072227);
Color secondary = const Color(0xff35858B);
Color primaryLight = const Color(0xff4FBDBA);
Color secondaryLight = const Color(0xffAEFEFF);

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  // Defining a Form Key
  final _formKey = GlobalKey<FormState>();

  // Firebase Auth
  // final _auth = FirebaseAuth.instance;

  // Defining Editing Controller
  final TextEditingController firstNameEditingController =
  TextEditingController();
  final TextEditingController lastNameEditingController =
  TextEditingController();
  final TextEditingController phoneNumberEditingController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Creating Form Fields
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
      onSaved: (value) {
        firstNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_circle_outlined),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "First Name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // Last name Text Field
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
      onSaved: (value) {
        lastNameEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle_outlined),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Last Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    // Phone Number Text field
    final phoneNumberField = TextFormField(
      autofocus: false,
      controller: phoneNumberEditingController,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter your phone number.");
        }
        // reg expression for email validation
        if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
          return ("Please enter a Valid 10-Phone Number");
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.phone),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Phone Number",
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
              phoneNumberEditingController.text);
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
            child: Padding(
              padding: const EdgeInsets.all(35),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // const SizedBox(
                    //   height: 150,
                    //   child: Image(
                    //     image: AssetImage("assets/images/logo.png"),
                    //     width: 80,
                    //     height: 80,
                    //     fit: BoxFit.contain,
                    //   ),
                    // ),
                    firstNameField,
                    const SizedBox(height: 15),
                    lastNameField,
                    const SizedBox(height: 15),
                    phoneNumberField,
                    const SizedBox(height: 15),
                    registerButton,
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String firstName, String lastName, String phoneNumber) async {
    print("the value of first Name is ");
    print(firstName);
    print("the value of last Name is ");
    print(lastName);
    print("the value of phone number is ");
    print(phoneNumber);
    if (_formKey.currentState!.validate()) {
      print("insdie the signin the form is valid");
      try {
        final response = await http.post(
          Uri.parse('http://192.168.29.50:3500/api/v1/user/signup'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "phoneNumber": phoneNumber,
            "firstName": firstName,
            "lastName": lastName
          }),
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "OTP sent successfully!");

          // Navigate to OTPScreen and pass the phone number
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(phoneNumber: phoneNumber)),
          );
        } else {
          // Handle error response
          final errorMessage =
              jsonDecode(response.body)['error'] ?? 'Failed to send OTP';
          Fluttertoast.showToast(msg: errorMessage);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e");
      }
    }
  }
}
