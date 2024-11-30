import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';
import 'package:pexllite/screens/FullScreenImageViewer.dart';
import 'package:pexllite/screens/ProfileImagePreviewScreen%20.dart';
import 'package:pexllite/screens/welcome.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailsScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupDetailsScreenState createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool isLoading = false;
  Map<String, dynamic>? groupDetails;

  String _token = '';
  String _currentUserId = '';
  String profilePicUrl = '';
  String? _profileImage;
  bool _isPickingFile = false; // Flag to track if file picking is in progress

  @override
  void initState() {
    super.initState();
    _fetchTokenAndUserId();
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
              token:_token,
              isProfile: false,
              groupId: widget.groupId,
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


  Future<void> _fetchTokenAndUserId() async {
    try {
      String? token = await HelperFunctions.getUserTokenSharedPreference();
      String? currentUserId = await HelperFunctions.getUserIdSharedPreference();
      print("The token and the current user ID are $token and $currentUserId");

      if (token != null && currentUserId != null && mounted) {
        setState(() {
          _token = token;
          _currentUserId = currentUserId;
        });
        await _fetchGroupDetails();
      } else {
        throw Exception("Token or User ID is null");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid User");
      if (mounted) {
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _fetchGroupDetails() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$baseurl/group/fetchDetails?groupId=${widget.groupId}'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          groupDetails = jsonDecode(response.body);
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch group details");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching group details: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<void> _removeMember(String memberId) async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseurl/group/removeMember'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupId': widget.groupId,
          'memberId': memberId,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Member removed successfully");
        await _fetchGroupDetails();
      } else {
        Fluttertoast.showToast(msg: "Failed to remove member");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error removing member: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Group Details',
          style: TextStyle(color: Colors.white),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupDetails == null
              ? const Center(child: Text("No details available"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Group Picture and Name
                      Center(
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: groupDetails!['photo'] != null && groupDetails!['photo'].isNotEmpty
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullScreenImageViewer(
                                            imageUrl: groupDetails!['photo'],
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: groupDetails!['photo'] != null && groupDetails!['photo'].isNotEmpty
                                    ? CachedNetworkImageProvider(groupDetails!['photo'])
                                    : null,
                                child: (groupDetails!['photo'] == null || groupDetails!['photo'].isEmpty)
                                    ? Icon(Icons.group, size: 60, color: Colors.grey[700])
                                    : null,
                              ),
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
                                  child: const Icon(Icons.camera_alt, 
                                  color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: Text(
                          groupDetails!['GroupName'] ?? 'Unnamed Group',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Number of members
                      Text(
                        'Number of Members: ${groupDetails!['users']?.length ?? 0}',
                        style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      // Member details
                      groupDetails!['users'] != null && groupDetails!['users'].isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: groupDetails!['users'].length,
                              itemBuilder: (context, index) {
                                final user = groupDetails!['users'][index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user['profilePic'] != null
                                        ? NetworkImage(user['profilePic'])
                                        : const AssetImage('assets/default_profile.png') as ImageProvider,
                                  ),
                                  title: Text('${user['firstName']} ${user['lastName']}'),
                                  subtitle: Text('Phone: ${user['phoneNumber']}'),
                                  trailing: 
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () => _removeMember(user['id']),
                                  ),
                                );
                              },
                            )
                          : const Center(child: Text("No members found")),
                    ],
                  ),
                ),
    );
  }
}
