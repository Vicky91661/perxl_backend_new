// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pexllite/constants.dart';
// import 'package:pexllite/helpers/helper_functions.dart';
// import 'package:pexllite/screens/home.dart';
// import 'dart:io';
// import 'package:pexllite/screens/welcome.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';

// class ProfileScreen extends StatefulWidget {
//   final String token;

//   const ProfileScreen({Key? key, required this.token}) : super(key: key);

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController phoneNumberController = TextEditingController();

//   String profilePicUrl = '';
//   String? _profileImage;
//   bool isLoadingDetails = false;

//   @override
//   void initState() {
//     super.initState();
//     getDetails();
//   }

//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png'],
//     );

//     if (result != null) {
//       setState(() {
//         _profileImage = result.files.single.path;
//       });
//     }
//     print("The image is $_profileImage");
//   }

//   void getDetails() async {
//     if (isLoadingDetails) return;
//     setState(() => isLoadingDetails = true);
//     try {
//       final response = await http.get(
//         Uri.parse('$baseurl/user/getuser'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           phoneNumberController.text = data['phoneNumber'].toString();
//           firstNameController.text = data['firstName'];
//           lastNameController.text = data['lastName'];
//           profilePicUrl = data['profilePic'];
//         });

//         Fluttertoast.showToast(msg: "User details loaded successfully!");
//       } else {
//         Fluttertoast.showToast(msg: "Failed to load user details");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Server not found");
//     } finally {
//       setState(() => isLoadingDetails = false);
//     }
//   }

//   // Function to pick an image from gallery
//   // Future<void> _pickImage() async {
//   //   final ImagePicker picker = ImagePicker();
//   //   final XFile? pickedImage =
//   //       await picker.pickImage(source: ImageSource.gallery);
//   //   if (pickedImage != null) {
//   //     setState(() {
//   //       _profileImage = pickedImage;
//   //     });
//   //   }
//   // }

//   Future<void> updateProfile() async {
//     String firstName = firstNameController.text;
//     String lastName = lastNameController.text;
//     //  print("Sending data - firstName: $firstName, lastName: $lastName");
//     try {
//       var response = await http.post(
//         Uri.parse('$baseurl/user/update'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json', // Ensure JSON content type
//         },
//         body: jsonEncode({"firstName": firstName, "lastName": lastName}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           firstNameController.text = data['firstName'];
//           lastNameController.text = data['lastName'];
//         });
//         Fluttertoast.showToast(msg: "Profile updated successfully!");
//       } else {
//         Fluttertoast.showToast(msg: "Failed to update profile.");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error updating profile.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit profile'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),
//               // Profile Picture and Edit Button
//               Center(
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       // Use random color or set it here
//                       backgroundImage: profilePicUrl.isNotEmpty
//                           ? NetworkImage(profilePicUrl) as ImageProvider
//                           : null,
//                       child: profilePicUrl.isEmpty
//                           ? Icon(Icons.home, size: 50, color: Colors.white)
//                           : null,
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: InkWell(
//                         onTap: _pickFile,
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: Colors.green,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(Icons.edit, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Center(
//                 child: Text(
//                   'Enter your name and add an optional profile picture',
//                   style: TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // First Name
//               TextFormField(
//                 controller: firstNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'First Name',
//                   border: OutlineInputBorder(),

//                   floatingLabelBehavior: FloatingLabelBehavior.always,
//                   floatingLabelAlignment: FloatingLabelAlignment.start,
//                   labelStyle: TextStyle(
//                     fontSize: 16.0,
//                     height: 0.7,
//                   ),
//                   contentPadding: EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 12.0),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Last Name
//               TextFormField(
//                 controller: lastNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Last Name',
//                   border: OutlineInputBorder(),
//                   floatingLabelBehavior: FloatingLabelBehavior.always,
//                   floatingLabelAlignment: FloatingLabelAlignment.start,
//                   labelStyle: TextStyle(
//                     fontSize: 16.0,
//                     height: 0.7,
//                   ),
//                   contentPadding: EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 12.0),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               // Phone Number (Not editable)
//               TextFormField(
//                 controller: phoneNumberController,
//                 readOnly: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone Number',
//                   border: OutlineInputBorder(),
//                   floatingLabelBehavior: FloatingLabelBehavior.always,
//                   floatingLabelAlignment: FloatingLabelAlignment.start,
//                   labelStyle: TextStyle(
//                     fontSize: 16.0,
//                     height: 0.7,
//                   ),
//                   contentPadding: EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 12.0),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               // Save Button
//               Center(
//                 child: ElevatedButton(
//                   onPressed: updateProfile,
//                   child: const Text('Save Changes'),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               // Logout Button
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     await HelperFunctions.saveUserLoggedInSharedPreference(
//                         false);
//                     await HelperFunctions.saveUserTokenSharedPreference('');
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (context) => WelcomeScreen()),
//                       (Route<dynamic> route) => false,
//                     );
//                   },
//                   child: const Text('Logout'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pexllite/constants.dart';
// import 'package:pexllite/helpers/helper_functions.dart';
// import 'package:pexllite/screens/home.dart';
// import 'dart:io';
// import 'package:pexllite/screens/welcome.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';

// class ProfileScreen extends StatefulWidget {
//   final String token;

//   const ProfileScreen({Key? key, required this.token}) : super(key: key);

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController phoneNumberController = TextEditingController();

//   String profilePicUrl = '';
//   String? _profileImage;
//   bool isLoadingDetails = false;

//   @override
//   void initState() {
//     super.initState();
//     getDetails();
//   }

//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png'],
//     );

//     if (result != null) {
//       setState(() {
//         _profileImage = result.files.single.path;
//       });
//     }
//     print("The image is $_profileImage");
//   }

//   void getDetails() async {
//     if (isLoadingDetails) return;
//     setState(() => isLoadingDetails = true);
//     try {
//       final response = await http.get(
//         Uri.parse('$baseurl/user/getuser'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           phoneNumberController.text = data['phoneNumber'].toString();
//           firstNameController.text = data['firstName'];
//           lastNameController.text = data['lastName'];
//           profilePicUrl = data['profilePic'];
//         });

//         Fluttertoast.showToast(msg: "User details loaded successfully!");
//       } else {
//         Fluttertoast.showToast(msg: "Failed to load user details");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Server not found");
//     } finally {
//       setState(() => isLoadingDetails = false);
//     }
//   }

//   Future<void> updateProfile() async {
//     String firstName = firstNameController.text;
//     String lastName = lastNameController.text;
//     try {
//       var response = await http.post(
//         Uri.parse('$baseurl/user/update'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({"firstName": firstName, "lastName": lastName}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           firstNameController.text = data['firstName'];
//           lastNameController.text = data['lastName'];
//         });
//         Fluttertoast.showToast(msg: "Profile updated successfully!");
//       } else {
//         Fluttertoast.showToast(msg: "Failed to update profile.");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error updating profile.");
//     }
//   }

//    @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//         backgroundColor: Colors.deepPurpleAccent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               // Profile Picture and Edit Button
//               Center(
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 55,
//                       backgroundColor: Colors.grey[300],
//                       backgroundImage: profilePicUrl.isNotEmpty
//                           ? NetworkImage(profilePicUrl) as ImageProvider
//                           : null,
//                       child: profilePicUrl.isEmpty
//                           ? Icon(Icons.person, size: 50, color: Colors.grey[700])
//                           : null,
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 4,
//                       child: InkWell(
//                         onTap: _pickFile,
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.blue,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(Icons.edit, color: Colors.white, size: 18),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Update your profile details',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//               const SizedBox(height: 20),
//               // First Name
//               TextFormField(
//                 controller: firstNameController,
//                 decoration: InputDecoration(
//                   hintText: 'First Name',
//                   hintStyle: TextStyle(color: Colors.grey[600]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Last Name
//               TextFormField(
//                 controller: lastNameController,
//                 decoration: InputDecoration(
//                   hintText: 'Last Name',
//                   hintStyle: TextStyle(color: Colors.grey[600]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               // Phone Number (read-only)
//               TextFormField(
//                 controller: phoneNumberController,
//                 readOnly: true,
//                 decoration: InputDecoration(
//                   hintText: 'Phone Number',
//                   hintStyle: TextStyle(color: Colors.grey[600]),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               // Save Button
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(45),
//                   backgroundColor: Colors.deepPurple,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: updateProfile,
//                 child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
//               ),
//               const SizedBox(height: 20),
//               // Logout Button
//               TextButton(
//                 onPressed: () async {
//                   await HelperFunctions.saveUserLoggedInSharedPreference(false);
//                   await HelperFunctions.saveUserTokenSharedPreference('');
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => WelcomeScreen()),
//                     (Route<dynamic> route) => false,
//                   );
//                 },
//                 child: const Text(
//                   'Logout',
//                   style: TextStyle(
//                     color: Colors.redAccent,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:pexllite/screens/ProfileImagePreviewScreen%20.dart';
import 'package:pexllite/screens/home.dart';
import 'dart:io';
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
  String? _profileImage;
  bool isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  Future<void> _pickFile() async {
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
          ),
        ),
      );
      if (updatedUrl != null && updatedUrl is String) {
        setState(() {
          profilePicUrl = updatedUrl;
        });
      }
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
        setState(() {
          phoneNumberController.text = data['phoneNumber'].toString();
          firstNameController.text = data['firstName'];
          lastNameController.text = data['lastName'];
          profilePicUrl = data['profilePic'];
        });

        Fluttertoast.showToast(msg: "User details loaded successfully!");
      } else {
        Fluttertoast.showToast(msg: "Failed to load user details");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Server not found");
    } finally {
      setState(() => isLoadingDetails = false);
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
        title: const Text('Edit Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
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
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: profilePicUrl.isNotEmpty
                          ? NetworkImage(profilePicUrl) as ImageProvider
                          : null,
                      child: profilePicUrl.isEmpty
                          ? Icon(Icons.person, size: 60, color: Colors.grey[700])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 8,
                      child: InkWell(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'First Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Last Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your last name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: phoneNumberController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Your phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: updateProfile,
                child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await HelperFunctions.saveUserLoggedInSharedPreference(false);
                    await HelperFunctions.saveUserTokenSharedPreference('');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
