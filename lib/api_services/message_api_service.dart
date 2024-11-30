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
    // print("The token inside the getHeader is  $token");
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
      if (response.statusCode == 200) {
        // Decode the response body if status is OK
        final decodedResponse = jsonDecode(response.body);
        print("The RESPONSE FROM sendMessage is: $decodedResponse");
        return decodedResponse;
      } else {
        // Handle non-200 status codes
        print("Error in response: ${response.statusCode} ${response.reasonPhrase}");
        final errorResponse = jsonDecode(response.body);
        return errorResponse; // Or handle as needed
      }
    } catch (error) {
      print('Error in sendMessage API: $error');
      return {'error': 'Failed to send message. Please try again later.'};
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
      String filePath = body['filePath'];
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/message/sendfilemessage'));

      // Add headers
      var headers = await _getHeaders();
      request.headers.addAll(headers);
      // Add fields
      request.fields['taskId'] = body['taskId'];

      // Attach file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String uploadedUrl = responseData['url'];

        print("THE RESPONSE I GOT FROM FILE UPLOAD FUNCTION IS $uploadedUrl");

        Map<String, dynamic> messageData = {
          'taskId': body['taskId'],
          'message': uploadedUrl,
          'isMessage': false
        };
        var messageResponse = await sendMessage(messageData);
        print("The Resposne from the message update is $messageResponse");
        return messageResponse;
      } else {
        print('Error in sendFileMessage API: ${response.statusCode}');
      }
    } catch (error) {
      print('Error in sendFileMessage API: $error');
    }
  }
}
