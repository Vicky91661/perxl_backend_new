import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pexllite/helpers/helper_functions.dart';
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
  final TextEditingController profilePicController = TextEditingController();

  String phoneNumber = '';
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    getDetails();
  }
  void getDetails() async{
    
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
          padding: const EdgeInsets.all(16.0),
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
                      backgroundImage: _profileImage != null
                          ? FileImage(File(_profileImage!.path))
                          : const AssetImage(
                                  'assets/images/default_profile.png')
                              as ImageProvider,
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
                initialValue: phoneNumber,
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
                  onPressed: () async {
                    // Save updated profile info logic here
                    String firstName = firstNameController.text;
                    String lastName = lastNameController.text;

                    print("First Name: $firstName");
                    print("Last Name: $lastName");
                    print("the profile picture $_profileImage");
                    try {
                      final response = await http.post(
                        Uri.parse(
                            'http://192.168.29.50:3000/api/v1/user/update'),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "firstName": firstName,
                          "lastName": lastName,
                          "profilePic": _profileImage
                        }),
                      );

                      if (response.statusCode == 200) {
                        // Save the user Data to the system
                        await HelperFunctions.saveUserFirstNameSharedPreference(
                            firstName);
                        await HelperFunctions.saveUserLastNameSharedPreference(
                            lastName);
                        Fluttertoast.showToast(msg: "Successfully Updated");
                      } else {
                        Fluttertoast.showToast(
                            msg: "Not Able to Update The Details");
                      }
                    } catch (e) {
                      Fluttertoast.showToast(
                          msg: "Not Able to Update The Details");
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 30),
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Save updated profile info logic here
                    await HelperFunctions.saveUserLoggedInSharedPreference(
                        false);
                    await HelperFunctions.saveUserPhoneSharedPreference('');
                    await HelperFunctions.saveUserFirstNameSharedPreference('');
                    await HelperFunctions.saveUserLastNameSharedPreference('');
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
