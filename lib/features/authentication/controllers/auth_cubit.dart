import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  StreamSubscription<User?>? _authSubscription;

  AuthCubit() : super(AuthInitial()) {
    _init();
  }

  void _init() {
    final authRepo = AuthenticationRepository.instance;
    // Set initial state
    final currentUser = authRepo.currentUser;
    if (currentUser != null) {
      emit(Authenticated(currentUser));
    } else {
      emit(Unauthenticated());
    }

    // Subscribe to stream
    _authSubscription = authRepo.authStateChanges.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
