import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

import 'package:pexllite/constants.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  final String token;

  ImagePreviewScreen({required this.imagePath, required this.token});

  Future<void> uploadImage(BuildContext context) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseurl/user/uploadProfilePic'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      request.headers['Authorization'] = 'Bearer $token';
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var resposneData = jsonDecode(response.body);
        print("Inside the upload profile pic response $resposneData");
        String uploadedUrl = resposneData['url'];
        
        final responseUrl = await http.post(
          Uri.parse('$baseurl/user/updateProfilePic'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"url": uploadedUrl}),
        );
        if(responseUrl.statusCode == 200){
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image uploaded successfully!')),
          );
          // Navigate back to ProfileScreen with the updated image URL
          Navigator.pop(context, uploadedUrl);
        }else{
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Preview'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload),
            onPressed: () => uploadImage(context),
          ),
        ],
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}