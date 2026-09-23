import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const Duration _timeout = Duration(seconds: 20);

  static Future<void> saveToken(String token) async =>
      _storage.write(key: 'auth_token', value: token);

  static Future<String?> getToken() => _storage.read(key: 'auth_token');

  static Future<void> clearToken() async =>
      _storage.delete(key: 'auth_token');

  static Uri _uri(String endpoint) => Uri.parse('${ApiConfig.baseUrl}$endpoint');

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool auth = false,
  }) async {
    try {
      final response = await http
          .get(_uri(endpoint), headers: await _headers(auth: auth))
          .timeout(_timeout);
      return _decodeResponse(response);
    } on TimeoutException {
      return {'success': false, 'message': 'Server request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final response = await http
          .post(
            _uri(endpoint),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _decodeResponse(response);
    } on TimeoutException {
      return {'success': false, 'message': 'Server request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'POST',
        _uri('/profile/upload_profile_photo.php'),
      );
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(
        await http.MultipartFile.fromPath('profile_photo', imageFile.path),
      );
      final streamedResponse = await request.send().timeout(_timeout);
      return _decodeResponse(await http.Response.fromStream(streamedResponse));
    } on TimeoutException {
      return {'success': false, 'message': 'Server request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required File file,
    required String fieldName,
    required Map<String, String> fields,
    bool auth = false,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(endpoint));
      request.headers['Accept'] = 'application/json';
      if (auth) {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      final streamedResponse = await request.send().timeout(_timeout);
      return _decodeResponse(await http.Response.fromStream(streamedResponse));
    } on TimeoutException {
      return {'success': false, 'message': 'Server request timed out'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) {
      return {
        'success': false,
        'message': 'Empty server response (HTTP ${response.statusCode})',
      };
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {
        'success': false,
        'message': 'Invalid server response (HTTP ${response.statusCode})',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Server error (HTTP ${response.statusCode}): $body',
      };
    }
  }
}
