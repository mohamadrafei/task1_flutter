import 'package:job_management_system/core/storage/token_storage.dart';
import 'package:job_management_system/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:job_management_system/features/auth/data/models/login_request.dart';
import 'package:job_management_system/features/auth/data/models/login_response.dart';
import 'package:job_management_system/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<LoginResponse> login(String email, String password) async {
    final req = LoginRequest(email: email, password: password);
    final resp = await remoteDataSource.login(req);

    // save token for future calls
    await tokenStorage.saveToken(resp.token);

    return resp;
  }
}
