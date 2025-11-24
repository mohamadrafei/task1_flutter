import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/login_response.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final LoginResponse resp =
          await loginUseCase(event.email, event.password);

      emit(AuthSuccess(
        token: resp.token,
        userId: resp.userId,
        companyId: resp.companyId,
        roles: resp.roles,
      ));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
