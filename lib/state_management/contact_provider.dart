import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';

class ContactProvider with ChangeNotifier {
  List<dynamic> backendContacts = [];
  List<Contact> phoneContacts = [];
  List<dynamic> intersectedContacts = [];

  // Set backend contacts and update intersected contacts
  void setBackendContacts(List<dynamic> contacts) {
    backendContacts = contacts;
    _updateIntersectedContacts();
    notifyListeners();
  }

  // Set phone contacts and update intersected contacts
  void setPhoneContacts(List<Contact> contacts) {
    phoneContacts = contacts;
    _updateIntersectedContacts();
    notifyListeners();
  }

  // Method to find contacts that are present in both backendContacts and phoneContacts
  // void _updateIntersectedContacts() {
  //   intersectedContacts = backendContacts.where((backendContact) {
  //     final backendPhone = backendContact['phoneNumber'].toString();
  //     phoneContacts.any((phoneContact) {
  //       final normalizedNumber =
  //         _normalizePhoneNumber(phoneContact.phones.first.normalizedNumber);
  //     })
  //   }).toSet();

  // intersectedContacts = phoneContacts.where((phoneContact) {
  //   if (phoneContact.phones.isEmpty)
  //     return false; // Skip contacts without phone numbers

  //   final normalizedNumber =
  //       _normalizePhoneNumber(phoneContact.phones.first.normalizedNumber);
  //   return backendContacts.any((backendContact) {
  //     final backendPhone = backendContact['phoneNumber'].toString();
  //     return normalizedNumber == backendPhone;
  //   });
  // }).toList();

  //   notifyListeners();
  //   print("Intersected Contacts: $intersectedContacts");
  // }
  void _updateIntersectedContacts() {
    intersectedContacts = backendContacts.where((backendContact) {
      final backendPhone = backendContact['phoneNumber'].toString();
      return phoneContacts.any((phoneContact) {
        if (phoneContact.phones.isEmpty)
          return false; // Skip contacts without phone numbers

        String normalizedNumber =
            _normalizePhoneNumber(phoneContact.phones.first.normalizedNumber);
        return normalizedNumber == backendPhone;
      });
    }).toList();

    notifyListeners();
    print("Intersected Contacts (from backend): $intersectedContacts");
  }

  // Helper method to normalize phone number by removing country code
  String _normalizePhoneNumber(String phoneNumber) {
    final countryCodePattern = RegExp(r'^\+\d{2}');
    if (countryCodePattern.hasMatch(phoneNumber)) {
      phoneNumber = phoneNumber
          .substring(3); // Remove the first 3 characters for country code
    }
    return phoneNumber;
  }

  // Clear all contacts data
  void clearContacts() {
    backendContacts = [];
    phoneContacts = [];
    intersectedContacts = [];
    notifyListeners();
  }
}
