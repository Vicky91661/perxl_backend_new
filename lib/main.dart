import 'package:flutter/material.dart';
import 'package:pexllite/screens/home.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:pexllite/screens/login.dart';
// import 'package:pexllite/screens/otp.dart';
// import 'package:pexllite/screens/taskHome.dart';
// import './screens/registration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/welcome.dart';
import 'state_management/group_provider.dart';
import 'package:provider/provider.dart';
import 'state_management/user_provider.dart';
import 'constants.dart';

void main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => GroupProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  List<Contact> phoneContacts = []; // Contacts from phone

  @override
  void initState() {
    super.initState();
    // _getUserLoggedInStatus();
    _fetchPhoneContacts();
  }

 // Function to request contacts permission and fetch contacts
  Future<void> _fetchPhoneContacts() async {
    final permissionStatus = await Permission.contacts.status;
    if (permissionStatus.isGranted) {
      // If permission is granted, fetch the contacts
      await _getContacts();
    } else if (permissionStatus.isDenied) {
      // Request permission if not already granted
      if (await Permission.contacts.request().isGranted) {
        await _getContacts();
      } else {
        setState(() {
          phoneContacts = []; // Set empty if permission is denied
        });
      }
    }
  }

  // Function to fetch contacts from the phone
  Future<void> _getContacts() async {
    try {
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() => phoneContacts = contacts);
    } catch (e) {
      print("Error fetching contacts: $e");
    }
  }

  Future<void> _getUserLoggedInStatus() async {
    try {
      print("inside the _getUserLoggedInStatus function");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print("Initialized SharedPreferences");
      bool? isLoggedIn = prefs.getBool('ISLOGGEDIN');
      print("THE VALUE OF ISLOGGEDIN IS $isLoggedIn");
      if (isLoggedIn != null && mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
        });
      }
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
      });
      print("The error is $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Auth',
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        // home: _isLoggedIn ? const HomeScreen() : const WelcomeScreen(),
        home: WelcomeScreen());
  }
}
