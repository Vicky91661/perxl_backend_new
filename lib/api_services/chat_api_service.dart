import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pexllite/constants.dart';
import 'package:pexllite/helpers/helper_functions.dart';

class ChatApiService {
  final storage = FlutterSecureStorage();
  final String baseUrl = baseurl;

  Future<Map<String, String>> _getHeaders() async {
    String? token = await HelperFunctions.getUserTokenSharedPreference();
    return {
      'Authorization': token ?? '',
      'Content-Type': 'application/json',
    };
  }

  Future<dynamic> fetchAllChats() async {
    try {
      var headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/'),
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (error) {
      print('Error in fecthing the chats API: $error');
    }
  }

  Future<dynamic> addToGroup(Map<String, dynamic> body) async {
    try {
      var headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/groupAdd'),
        headers: headers,
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (error) {
      print('Error in sendMessage API: $error');
    }
  }

  Future<dynamic> renameGroup(Map<String, dynamic> body) async {
    try {
      var headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/group/rename'),
        headers: headers,
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (error) {
      print('Error in sendMessage API: $error');
    }
  }

  Future<dynamic> removeUser(Map<String, dynamic> body) async {
    try {
      var headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/group/remove'),
        headers: headers,
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (error) {
      print('Error in sendMessage API: $error');
    }
  }
}
