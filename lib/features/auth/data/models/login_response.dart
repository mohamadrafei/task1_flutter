class LoginResponse {
  final String token;
  final int userId;
  final int companyId;
  final List<String> roles;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.companyId,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      userId: json['userId'] as int,
      companyId: json['companyId'] as int,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
}
