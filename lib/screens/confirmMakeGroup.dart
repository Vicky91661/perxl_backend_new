import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pexllite/constants.dart';
import 'package:pexllite/screens/home.dart';

class ConfirmGroupCreation extends StatefulWidget {
  final List<dynamic> selectedUsers; // Pass selected users as a list of maps
  final String token;
  const ConfirmGroupCreation(
      {super.key, required this.token, required this.selectedUsers});

  @override
  _ConfirmGroupCreationState createState() => _ConfirmGroupCreationState();
}

class _ConfirmGroupCreationState extends State<ConfirmGroupCreation> {
  final TextEditingController _groupNameController = TextEditingController();
  bool _isCreating = false; // To track if group creation is in progress

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New group"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createGroup,
            child: Text(
              "Create",
              style: TextStyle(
                color: _isCreating ? Colors.grey : Colors.blue,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group name input
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: "Group name",
                prefixIcon: Icon(Icons.camera_alt),
              ),
            ),
            SizedBox(height: 20),

            // Display selected users
            Text("Members: ${widget.selectedUsers.length}"),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: widget.selectedUsers.map((user) {
                return Chip(
                  label: Text(user['firstName'] + " " + user['lastName']),
                  avatar: CircleAvatar(
                    backgroundImage: NetworkImage(user[
                        'profilePic']), // Assuming each user has a profilePicUrl
                  ),
                  onDeleted: () {
                    setState(() {
                      widget.selectedUsers.remove(user); // Allow user removal
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle group creation
  Future<void> _createGroup() async {
    setState(() {
      _isCreating = true;
    });

    try {
      // Call the backend API to create the group
      // Assuming you have a function to make the API call
      String groupName = _groupNameController.text;
      await createGroupAPI(widget.selectedUsers, groupName);
      
      
      // Navigate back to home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
      
      
    } catch (e) {
      // Handle any errors here, such as showing a snackbar
       Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  // Mockup of an API call function
  Future<bool> createGroupAPI(List<dynamic> users, String groupName) async {
    // Replace this with the actual API call code
    // For example, you might use Dio or http package to make a POST request
    print("Group created with name: $groupName and members: $users");
    try {
      final response = await http.post(
        Uri.parse('$baseurl/group/creategroup'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"GroupName": groupName, "users": users}),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Successfully created the Group");
        return true;
      } else {
        Fluttertoast.showToast(msg: "Group not created");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Group not created");
       return false;
    }
  }
}
