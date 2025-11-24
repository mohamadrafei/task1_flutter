import 'dart:convert';

import 'package:http/http.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    final Response resp = await apiClient.post(
      '/auth/login', // backend: POST /api/auth/login
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(resp.body);
      return LoginResponse.fromJson(json);
    } else {
      throw Exception('Login failed: ${resp.statusCode} - ${resp.body}');
    }
  }
}
