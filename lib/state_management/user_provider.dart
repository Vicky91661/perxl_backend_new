import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String id = '';
  String phoneNumber = '';
  String profilePic = '';
  String firstName = '';
  String lastName = '';

  void setUser(Map<String, dynamic> userData) {
    id = userData['_id'] ?? '';
    phoneNumber = userData['phoneNumber'] ?? '';
    profilePic = userData['profilePic'] ?? '';
    firstName = userData['firstName'] ?? '';
    lastName = userData['lastName'] ?? '';
    notifyListeners();
  }
}
