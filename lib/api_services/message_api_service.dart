import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';

class MessageApiService {
  final storage = FlutterSecureStorage();
  final String baseUrl = baseurl;

  Future<Map<String, String>> _getHeaders() async {
    String? token = await HelperFunctions.getUserTokenSharedPreference();
    print("The token inside the getHeader is  $token");
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<dynamic> sendMessage(Map<String, dynamic> body) async {
    try {
      var headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/message/sendmessage/'),
        headers: headers,
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (error) {
      print('Error in sendMessage API: $error');
    }
  }

  Future<List<Map<String, dynamic>>?> fetchMessages(String taskId) async {
    try {
      print(
          "The group id inside the fetchMessages of message api service is $taskId");
      var headers = await _getHeaders();
      print("The Header is $headers");
      final response = await http.get(
        Uri.parse('$baseUrl/message/fetchMessages?taskId=$taskId'),
        headers: headers,
      );

      // Check if the response was successful
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(responseData['messages'] ?? []);
      } else {
        print('Error in fetchMessages API: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error in fetchMessages API: $error');
      return [];
    }
  }

  Future<dynamic> sendFileMessage(Map<String, dynamic> body) async {
    try {
      String? filePath = body['filePath'];
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/message/sendfilemessage'));

      // Add headers
      var headers = await _getHeaders();
      request.headers.addAll(headers);

      // Add text fields
      request.fields['taskId'] = body['taskId'];
      if (body['message'] != null) {
        request.fields['message'] = body['message'];
      }

      // Attach file if path is provided
      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          filePath,
        ));
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print("THE RESPONSE I GOT FROM FILE UPLOAD FUNCTION IS ${jsonDecode(response.body)}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return the parsed response
      } else {
        print('Error in sendFileMessage API: ${response.statusCode}');
      }
    } catch (error) {
      print('Error in sendFileMessage API: $error');
    }
  }
}
