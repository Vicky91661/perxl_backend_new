import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pexllite/screens/home.dart';


class ConfirmGroupCreation extends StatefulWidget {
  final List<dynamic>
      selectedUsers; // Pass selected users as a list of maps
  final String token;
  ConfirmGroupCreation({super.key, required this.token,required this.selectedUsers});

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
                  label: Text(user['name']),
                  avatar: CircleAvatar(
                    backgroundImage: NetworkImage(user[
                        'profilePicUrl']), // Assuming each user has a profilePicUrl
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

      // Navigate back or show success message after creating the group
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors here, such as showing a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create group: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  // Mockup of an API call function
  Future<void> createGroupAPI(
      List<dynamic> users, String groupName) async {
    // Replace this with the actual API call code
    // For example, you might use Dio or http package to make a POST request
    print("Group created with name: $groupName and members: $users");
    try {
        final response = await http.post(
          Uri.parse('http://192.168.29.50:3500/api/v1/group/creategroup'),
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"GroupName":groupName , "users": users}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Assuming `data` contains the user information

          String userPhone = data['phoneNumber'];
          String firstName = data['firstName'];
          String lastName = data['lastName'];
          String token = data['token'];
          print("the phone number is $userPhone");
          print("the firstName  is $firstName");
          print("the lastName is $lastName");
          print("the token is $token");
          Fluttertoast.showToast(msg: "OTP Verified Successfully!");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(token: token,)),
            (Route<dynamic> route) => false,
          );
          // Save the user Data to the system
          // await HelperFunctions.saveUserLoggedInSharedPreference(true);
          // if (userPhone != null) {
          //   await HelperFunctions.saveUserPhoneSharedPreference(userPhone);
          // }
          // if (firstName != null) {
          //   await HelperFunctions.saveUserFirstNameSharedPreference(firstName);
          // }
          // if (lastName != null) {
          //   await HelperFunctions.saveUserLastNameSharedPreference(lastName);
          // }
        } else {
          Fluttertoast.showToast(msg: "Group not created");
        } 
        
      } catch (e) {
        Fluttertoast.showToast(msg: "Group not created");
      }


  }
}
