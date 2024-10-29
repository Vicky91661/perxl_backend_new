import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String id = '';
  String email = '';
  String profilePic = '';
  String name = '';

  void setUser(Map<String, dynamic> userData) {
    id = userData['id'] ?? '';
    email = userData['email'] ?? '';
    profilePic = userData['profilePic'] ?? '';
    name = userData['name'] ?? '';
    notifyListeners();
  }
}
