part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final int userId;
  final int companyId;
  final List<String> roles;

  const AuthSuccess({
    required this.token,
    required this.userId,
    required this.companyId,
    required this.roles,
  });

  bool get isAdminLike =>
      roles.contains('ADMIN') || roles.contains('COMPANY_ADMIN') || roles.contains('DISPATCHER');

  bool get isTechnician => roles.contains('TECHNICIAN');

  @override
  List<Object?> get props => [token, userId, companyId, roles];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
