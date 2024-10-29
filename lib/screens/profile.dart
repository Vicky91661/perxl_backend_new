import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:pexllite/screens/home.dart';
import 'dart:io';
import 'package:pexllite/screens/welcome.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String profilePicUrl = '';
  XFile? _profileImage;
  bool isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  void getDetails() async {
    if (isLoadingDetails) return;
    setState(() => isLoadingDetails = true);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.29.50:3500/api/v1/user/getuser'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          phoneNumberController.text = data['phoneNumber'].toString();
          firstNameController.text = data['firstName'];
          lastNameController.text = data['lastName'];
          profilePicUrl = data['profilePic'];
        });

        // Fluttertoast.showToast(msg: "User details loaded successfully!");
      } else {
        // Fluttertoast.showToast(msg: "Failed to load user details");
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Server not found");
    }finally{
       setState(() => isLoadingDetails = false);
    }
  }

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
    }
  }

  Future<void> updateProfile() async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
     print("Sending data - firstName: $firstName, lastName: $lastName");
    try {
      var response = await http.post(
        Uri.parse('http://192.168.29.50:3500/api/v1/user/update'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',  // Ensure JSON content type
        },
        body: jsonEncode({"firstName": firstName, "lastName": lastName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          firstNameController.text = data['firstName'];
          lastNameController.text = data['lastName'];
        });
        // Fluttertoast.showToast(msg: "Profile updated successfully!");
      } else {
        // Fluttertoast.showToast(msg: "Failed to update profile.");
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: "Error updating profile.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Profile Picture and Edit Button
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      // Use random color or set it here
                      backgroundImage: profilePicUrl.isNotEmpty
                          ? NetworkImage(profilePicUrl) as ImageProvider
                          : null,
                      child: profilePicUrl.isEmpty
                          ? Icon(Icons.home, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Enter your name and add an optional profile picture',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              // First Name
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Last Name
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Phone Number (Not editable)
              TextFormField(
                controller: phoneNumberController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: updateProfile,
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 30),
              // Logout Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // await HelperFunctions.saveUserLoggedInSharedPreference(false);
                    // await HelperFunctions.saveUserPhoneSharedPreference('');
                    // await HelperFunctions.saveUserFirstNameSharedPreference('');
                    // await HelperFunctions.saveUserLastNameSharedPreference('');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
