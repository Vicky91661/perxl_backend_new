import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:pexllite/screens/home.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pexllite/screens/taskHome.dart';
import 'package:pexllite/state_management/contact_provider.dart';
import 'package:pexllite/utils/MyCustomNotification.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import './screens/welcome.dart';
import 'state_management/group_provider.dart';
import 'package:provider/provider.dart';
import 'state_management/user_provider.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MyCustomNotification.initNotification();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => GroupProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => ContactProvider()),
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
  String _token = '';
  List<Contact> phoneContacts = []; // Contacts from phone

  @override
  void initState() {
    super.initState();
    _getUserLoggedInStatusandToken();
    _fetchPhoneContacts();
    MyCustomNotification.getFcmToken();
    setupFlutterNotifications();
  }

  void setupFlutterNotifications() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    print("Inside the setupFlutterNotifications");
    MyCustomNotification.getFirebaseMesagingInBackground();
    MyCustomNotification.getFirebaseMesagingInForeground(context);
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _fetchBackendContacts() async {
    print("INSIDE THE BACKEND USERS "); // Fetch contacts from the backend
    try {
      if (_token.isEmpty) {
        print("Token is empty");
        return;
      }
      final response = await http.get(
        Uri.parse('$baseurl/user/allusers'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json', // Ensure JSON content type
        },
      );

      if (response.statusCode == 200) {
        final usersData = jsonDecode(response.body);
        // print("THE BACKEND USERS RESPONSE IS $usersData");
        final contacts = usersData['users'];
        Provider.of<ContactProvider>(context, listen: false)
            .setBackendContacts(contacts);
      }
    } catch (e) {
      print("Error fetching contacts from backend: $e");
    }
  }

  Future<void> _fetchPhoneContacts() async {
    final permissionStatus = await Permission.contacts.status;
    if (permissionStatus.isGranted) {
      // Fetch contacts with properties like normalized phone numbers
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      Provider.of<ContactProvider>(context, listen: false)
          .setPhoneContacts(contacts);
    } else if (permissionStatus.isDenied) {
      if (await Permission.contacts.request().isGranted) {
        await _fetchPhoneContacts(); // Retry if permission is granted
      } else {
        Provider.of<ContactProvider>(context, listen: false)
            .setPhoneContacts([]);
      }
    }
  }

  // Function to fetch contacts from the phone
  Future<void> _getContacts() async {
    try {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: false);

      print("The user's Phone Contact $contacts");
      Provider.of<ContactProvider>(context, listen: false)
          .setPhoneContacts(contacts);
      // print("The user's Phone Contact $contacts");
    } catch (e) {
      print("Error fetching contacts: $e");
    }
  }

  Future<void> _getUserLoggedInStatusandToken() async {
    try {
      // print("inside the _getUserLoggedInStatusandToken function");
      bool? isLoggedIn =
          await HelperFunctions.getUserLoggedInSharedPreference();
      String? token = await HelperFunctions.getUserTokenSharedPreference();

      print("THE VALUE OF ISLOGGEDIN IS $isLoggedIn");
      print("THE VALUE OF TOKEN IS $token");

      if (isLoggedIn != null && mounted) {
        String? token = await HelperFunctions.getUserTokenSharedPreference();
        print("THE VALUE OF TOKEN IS $token");
        if (token != null && mounted) {
          setState(() {
            _isLoggedIn = isLoggedIn;
            _token = token;
          });
          _fetchBackendContacts();
        }
      }
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _token = '';
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
        home: _isLoggedIn ? const HomeScreen() : const WelcomeScreen());
  }
}
