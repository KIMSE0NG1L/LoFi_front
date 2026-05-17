import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static String get baseUrl => Platform.isAndroid
      ? 'http://10.0.2.2:3000/api'
      : 'http://localhost:3000/api';
  static const String _tokenKey = 'access_token';
  static const String _emailKey = 'user_email';

  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);

  Future<String?> get token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String?> get savedEmail async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _request('GET', path, query: query);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) {
    return _request('POST', path, body: body);
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) {
    return _request('PATCH', path, body: body);
  }

  Future<dynamic> delete(String path) {
    return _request('DELETE', path);
  }

  Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse('$baseUrl/upload/image');
    final request = await _client.postUrl(uri);

    final savedToken = await token;
    if (savedToken != null && savedToken.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $savedToken');
    }

    final boundary = 'LoFiBoundary${DateTime.now().millisecondsSinceEpoch}';
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );

    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final ext = fileName.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final fileBytes = await imageFile.readAsBytes();

    final Uint8List prefix = utf8.encode(
      '--$boundary\r\n'
      'Content-Disposition: form-data; name="image"; filename="$fileName"\r\n'
      'Content-Type: $mimeType\r\n\r\n',
    );
    final Uint8List suffix = utf8.encode('\r\n--$boundary--\r\n');

    request.contentLength = prefix.length + fileBytes.length + suffix.length;
    request.add(prefix);
    request.add(fileBytes);
    request.add(suffix);

    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    final data = jsonDecode(text);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map && data['message'] is String
          ? data['message'] as String
          : 'Upload failed (${response.statusCode})';
      throw ApiException(response.statusCode, message);
    }

    return (data as Map<String, dynamic>)['url'] as String;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final base = Uri.parse('$baseUrl$path');
    final uri = query == null ? base : base.replace(queryParameters: query);
    final request = await _client.openUrl(method, uri);
    request.headers.contentType = ContentType.json;

    final savedToken = await token;
    if (savedToken != null && savedToken.isNotEmpty) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $savedToken',
      );
    }

    if (body != null) {
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    final data = text.isEmpty ? null : jsonDecode(text);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data is Map && data['message'] is String
          ? data['message'] as String
          : 'API request failed (${response.statusCode})';
      throw ApiException(response.statusCode, message);
    }

    return data;
  }
}
