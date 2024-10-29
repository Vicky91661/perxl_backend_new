import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pexllite/screens/confirmMakeGroup.dart';

class MakeGroupScreen extends StatefulWidget {
  final String token;

  const MakeGroupScreen({Key? key, required this.token}) : super(key: key);

  @override
  _MakeGroupScreenState createState() => _MakeGroupScreenState();
}

class _MakeGroupScreenState extends State<MakeGroupScreen> {
  List<dynamic> backendContacts = []; // Contacts from backend
  List<Contact> phoneContacts = []; // Contacts from phone
  List<dynamic> intersectedContacts = []; // Intersected contacts to display
  List<dynamic> selectedContacts = []; // Track selected contacts
  List<dynamic> filteredContacts = []; // For search filtering
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBackendContacts();
    _fetchPhoneContacts();
  }

  Future<void> _fetchBackendContacts() async {
    // Fetch contacts from the backend
    try {
      final response =
          await http.get(Uri.parse('/api/v1/user/allusers'), headers: {
        'Authorization': 'Bearer ${widget.token}',
      });

      if (response.statusCode == 200) {
        setState(() {
          backendContacts = jsonDecode(
              response.body); // Assuming response is a list of contacts
        });
        _findIntersectedContacts();
      }
    } catch (e) {
      print("Error fetching contacts from backend: $e");
    }
  }

  void getContact() async {
    Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      phoneContacts = contacts.toList();
    });
  }

  Future<void> _fetchPhoneContacts() async {
    // Request permission and fetch contacts from the phone
    if (await Permission.contacts.isGranted) {
      // Fetch Contact
      getContact();
       _findIntersectedContacts();
    } else {
      await Permission.contacts.request();
    }
  }

  void _findIntersectedContacts() {
    if (backendContacts.isNotEmpty && phoneContacts.isNotEmpty) {
      // Find intersection between backend contacts and phone contacts by phone number
      setState(() {
        intersectedContacts = backendContacts.where((backendContact) {
          String backendPhone = backendContact[
              'phoneNumber']; // Assuming each backend contact has a 'phone' field
          return phoneContacts.any((phoneContact) =>
              phoneContact.phones?.any((p) => p.value == backendPhone) ??
              false);
        }).toList();

        filteredContacts =
            intersectedContacts; // Initialize filtered contacts for display
      });
    }
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredContacts = intersectedContacts
          .where((contact) =>
              contact['name'].toLowerCase().contains(query.toLowerCase()) ||
              contact['phone'].contains(query))
          .toList();
    });
  }

  void _toggleSelection(dynamic contact) {
    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        selectedContacts.add(contact);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add members'),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to the next screen or perform action with selected contacts
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConfirmGroupCreation(
                          token: widget.token,
                          selectedUsers: selectedContacts)));
            },
            child: Text(
              'Next',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _handleSearch,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Search name or number',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                final isSelected = selectedContacts.contains(contact);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        contact['photo'] ?? 'https://via.placeholder.com/150'),
                  ),
                  title: Text(contact['name']),
                  subtitle: Text(contact['status'] ?? ''),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(contact),
                  ),
                  onTap: () => _toggleSelection(contact),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
