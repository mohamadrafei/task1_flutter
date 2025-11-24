import '../../data/models/login_response.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResponse> call(String email, String password) {
    return repository.login(email, password);
  }
}
