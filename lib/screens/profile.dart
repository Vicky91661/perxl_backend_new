import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:pexllite/screens/FullScreenImageViewer.dart';
import 'package:pexllite/screens/ProfileImagePreviewScreen%20.dart';
import 'package:pexllite/screens/home.dart';
import 'package:pexllite/screens/welcome.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

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
  bool isLoadingDetails = false;
  String? _profileImage;
  bool _isPickingFile = false; // Flag to track if file picking is in progress

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  Future<void> _pickFile() async {
    if (_isPickingFile) return; // Prevent multiple concurrent calls

    setState(() {
      _isPickingFile = true; // Set flag to true when picking starts
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _profileImage = result.files.single.path;
        });

        final updatedUrl = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(
              imagePath: _profileImage!,
              token: widget.token,
              isProfile: true,
              groupId: '',
            ),
          ),
        );

        if (updatedUrl != null && updatedUrl is String) {
          setState(() {
            profilePicUrl = updatedUrl;
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error while picking file: ${e.toString()}");
    } finally {
      setState(() {
        _isPickingFile = false; // Reset flag when picking completes
      });
    }
  }

  void getDetails() async {
    if (isLoadingDetails) return;
    setState(() => isLoadingDetails = true);
    try {
      final response = await http.get(
        Uri.parse('$baseurl/user/getuser'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            phoneNumberController.text = data['phoneNumber'].toString();
            firstNameController.text = data['firstName'];
            lastNameController.text = data['lastName'];
            profilePicUrl = data['profilePic'];
          });
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to load user details");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Server not found");
    } finally {
      if (mounted) {
        setState(() => isLoadingDetails = false);
      }
    }
  }

  Future<void> updateProfile() async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    try {
      var response = await http.post(
        Uri.parse('$baseurl/user/update'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"firstName": firstName, "lastName": lastName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          firstNameController.text = data['firstName'];
          lastNameController.text = data['lastName'];
        });
        Fluttertoast.showToast(msg: "Profile updated successfully!");
      } else {
        Fluttertoast.showToast(msg: "Failed to update profile.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating profile.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              await HelperFunctions.saveUserLoggedInSharedPreference(false);
              await HelperFunctions.saveUserTokenSharedPreference('');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(
              Icons.logout,
              color: kWhiteColor,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(color: kWhiteColor),
            )),
      ),
      body: isLoadingDetails
        ? const Center(child: CircularProgressIndicator())
        :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Profile Picture and Edit Button
              Center(
                child: Stack(
                  children: [
                    InkWell(
                      onTap: profilePicUrl.isNotEmpty
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImageViewer(
                                      imageUrl: profilePicUrl),
                                ),
                              );
                            }
                          : null, // Disable onTap if the profilePicUrl is empty
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: profilePicUrl.isNotEmpty
                            ? CachedNetworkImageProvider(
                                profilePicUrl) // Use CachedNetworkImageProvider
                            : null,
                        child: profilePicUrl.isEmpty
                            ? Icon(Icons.person,
                                size: 60, color: Colors.grey[700])
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 8,
                      child: InkWell(
                        onTap: _pickFile, // Method to pick a new file or image
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'First Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Set background color to white
                  hintText: 'Enter your first name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Last Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Set background color to white
                  hintText: 'Enter your last name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              TextFormField(
                controller: phoneNumberController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Set background color to white
                  hintText: 'Your phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: updateProfile,
                child:
                    const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
