import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pexllite/constants.dart';
import 'registration.dart';
import 'otp.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Defining form Key
  final _formKey = GlobalKey<FormState>();

  // Define Editing Controller for Phone
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Creating Fields to enter the Phone Number
    // Form Phone Number Fields
    final emailField = TextFormField(
      autofocus: false,
      controller: phoneController,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter your Phone Number.");
        }
        // reg expression for phone number validation
        if (!RegExp(r"^[0-9]{10}$").hasMatch(value)) {
          return ("Please enter a Valid 10-Phone Number");
        }
        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // Set background color to white
        prefixIcon: const Icon(Icons.phone),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Phone Number",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    // OTP Button
    final loginButton = Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      color: primary,
      child: MaterialButton(
        onPressed: () {
          signIn(phoneController.text);
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
        title: const Text("Login",style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
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
                    emailField,
                    const SizedBox(height: 30),
                    loginButton,
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Don't have an Account? ",
                          style: TextStyle(fontSize: 14, color: primary),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationScreen()));
                          },
                          child: const Text(
                            "Sign up.",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primary),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Login Function
  void signIn(String phoneNumber) async {
    print("the phone number is ");
    print(phoneNumber);
    if (_formKey.currentState!.validate()) {
      print("inside the signin the form is valid");
      try {
        final response = await http.post(
          Uri.parse('$baseurl/user/signin'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phoneNumber": phoneNumber}),
        );
        print("The response I got");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("successful response $data");
          // Fluttertoast.showToast(msg: "OTP sent successfully!");
          print("after the toast");
          // Navigate to OTPScreen and pass the phone number
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(phoneNumber: phoneNumber)),
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
