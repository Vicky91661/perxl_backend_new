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

  Future<List<Map<String, dynamic>>?> fetchMessages(String groupId) async {
    try {
      print(
          "The group id inside the fetchMessages of message api service is $groupId");
      var headers = await _getHeaders();
      print("The Header is $headers");
      final response = await http.get(
        Uri.parse('$baseUrl/message/fetchMessages?groupId=$groupId'),
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
}
