// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class ApiClient {
  final String baseUrl;
  final http.Client httpClient;
  final TokenStorage tokenStorage;

  ApiClient({
    required this.baseUrl,
    required this.httpClient,
    required this.tokenStorage,
  });

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await tokenStorage.getToken();

    final headers = <String, String>{};
    if (json) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String path) async {
    return await httpClient.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );
  }

  Future<http.Response> post(String path, {Object? body}) async {
    return await httpClient.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body,
    );
  }

  Future<http.Response> put(String path, {Object? body}) async {
    return await httpClient.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: body,
    );
  }

  // 🔹 NEW: multipart upload (no JSON content-type)
  Future<http.StreamedResponse> uploadMultipart({
    required String path,
    required List<http.MultipartFile> files,
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    // No JSON header here:
    final headers = await _headers(json: false);
    request.headers.addAll(headers);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    request.files.addAll(files);

    return await request.send();
  }
}
