
import 'package:flutter/material.dart';
import 'package:pexllite/screens/login.dart';
import 'package:pexllite/screens/otp.dart';
import 'package:pexllite/screens/registration.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG handling
import '../../../constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Welcome text
              const Text(
                "Welcome to PerXL Lite",
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 40),
              // Logo image
              SvgPicture.asset(
                'assets/images/chat.svg', // Replace with your logo path
                height: 250, // Adjust the size according to your needs
              ),
            
              const SizedBox(height: 30),
              // Sign In button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  minimumSize: const Size(270, 50),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              // Sign Up button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryLightColor,
                  minimumSize: const Size(270, 50),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
