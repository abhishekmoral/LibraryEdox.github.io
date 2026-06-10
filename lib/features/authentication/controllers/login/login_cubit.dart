import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}

class LoginCubit extends Cubit<LoginState> {
  final _authRepo = AuthenticationRepository.instance;

  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      await _authRepo.loginWithEmailAndPassword(email, password);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
