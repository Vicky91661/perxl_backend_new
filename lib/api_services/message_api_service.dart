import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MessageApiService {
  final storage = FlutterSecureStorage();
  final String baseUrl = 'http://localhost:3000/api/v1/';

  Future<Map<String, String>> _getHeaders() async {
    String? token = await storage.read(key: 'userToken');
    return {'Authorization': token ?? ''};
  }

  Future<dynamic> sendMessage(Map<String, dynamic> body) async {
    try {
      var headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/message/'),
        headers: headers,
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (error) {
      print('Error in sendMessage API: $error');
    }
  }

  Future<dynamic> fetchMessages(String chatId) async {
    try {
      var headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/message/$chatId'),
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (error) {
      print('Error in fetchMessages API: $error');
    }
  }
}
