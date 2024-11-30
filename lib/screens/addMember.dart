import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:pexllite/screens/confirmMakeGroup.dart';
import 'package:pexllite/screens/welcome.dart';
import 'package:pexllite/state_management/contact_provider.dart';
import 'package:provider/provider.dart';

class MakeGroupScreen extends StatefulWidget {
  final String groupdId;

  const MakeGroupScreen({super.key, required this.groupdId});

  @override
  _MakeGroupScreenState createState() => _MakeGroupScreenState();
}

class _MakeGroupScreenState extends State<MakeGroupScreen> {
  List<dynamic> selectedContacts = []; // Track selected contacts
  List<dynamic> filteredContacts = []; // For search filtering
  String searchQuery = '';
  
  String _token = '';
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fetchTokenandUserId();
    _filterIntersectedContacts(); // Initialize filtered contacts with intersectedContacts
  }

  Future<void> _fetchTokenandUserId() async {
    try {
      String? token = await HelperFunctions.getUserTokenSharedPreference();
      String? currentUserid = await HelperFunctions.getUserIdSharedPreference();
      print("THe token and the cureent user id is $token and $currentUserid");
      if (token != null && currentUserid != null && mounted) {
        setState(() {
          _token = token;
          _currentUserId = currentUserid;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid User");
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredContacts = Provider.of<ContactProvider>(context, listen: false)
          .intersectedContacts
          .where((contact) =>
              contact['firstName']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              contact['lastName'].toLowerCase().contains(query.toLowerCase()) ||
              contact['phoneNumber'].contains(query))
          .toList();
    });
  }

  // Initialize filteredContacts with intersectedContacts initially
  void _filterIntersectedContacts() {
    List<dynamic> intersectedContacts =
        Provider.of<ContactProvider>(context, listen: false)
            .intersectedContacts;
    setState(() {
      filteredContacts = intersectedContacts;
    });
    print(
        "The intersected contact is INSIDE THE MAKE GROUPS $intersectedContacts");
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
        title: const Text(
          'Add members',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: selectedContacts.isNotEmpty
                ? () {
                    // Navigate to the next screen with selected contacts
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmGroupCreation(
                          token: _token,
                          selectedUsers: selectedContacts,
                        ),
                      ),
                    );
                  }
                : null, // Disable the button if fewer than 2 contacts are selected
            child: Text(
              'Add',
              style: TextStyle(
                color: selectedContacts.isNotEmpty
                    ? Colors.white
                    : Colors.grey, // Change text color to indicate availability
                fontSize: 16,
              ),
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
                    backgroundImage: NetworkImage(contact['profilePic']),
                  ),
                  title: Text(contact['firstName'] + " " + contact['lastName']),
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
