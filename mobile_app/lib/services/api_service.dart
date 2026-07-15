import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Uri _uri(String endpoint) {
    return Uri.parse('${ApiConfig.baseUrl}$endpoint');
  }

  static Future<Map<String, dynamic>> get(
      String endpoint, {
        bool auth = false,
      }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final response = await http.get(
      _uri(endpoint),
      headers: headers,
    );

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> body, {
        bool auth = false,
      }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final response = await http.post(
      _uri(endpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    final token = await getToken();

    final request = http.MultipartRequest(
      'POST',
      _uri('/profile/upload_profile_photo.php'),
    );

    request.headers['Accept'] = 'application/json';

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'profile_photo',
        imageFile.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> uploadFile(
      String endpoint, {
        required File file,
        required String fieldName,
        required Map<String, String> fields,
        bool auth = false,
      }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri(endpoint),
    );

    request.headers['Accept'] = 'application/json';

    if (auth) {
      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.fields.addAll(fields);

    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _decodeResponse(response);
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {
        'success': false,
        'message': 'Invalid server response',
      };
    } catch (_) {
      return {
        'success': false,
        'message': response.body.isEmpty
            ? 'Empty server response'
            : response.body,
      };
    }
  }
}