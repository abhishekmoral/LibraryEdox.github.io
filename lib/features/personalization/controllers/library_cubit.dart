import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/library/library_repository.dart';
import 'package:edox_library/features/authentication/models/library_model.dart';
import 'package:edox_library/bindings/dependency_injection.dart';

abstract class LibraryState {}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final LibraryModel library;
  LibraryLoaded(this.library);
}

class LibraryFailure extends LibraryState {
  final String message;
  LibraryFailure(this.message);
}

class LibraryCubit extends Cubit<LibraryState> {
  final LibraryRepository _libraryRepository = locator<LibraryRepository>();
  StreamSubscription<User?>? _authSubscription;

  LibraryCubit() : super(LibraryInitial()) {
    _init();
  }

  void _init() {
    _authSubscription = AuthenticationRepository.instance.authStateChanges.listen((user) {
      if (user != null) {
        fetchLibraryRecord(user.uid);
      } else {
        emit(LibraryInitial());
      }
    });
  }

  Future<void> fetchLibraryRecord(String userId) async {
    try {
      emit(LibraryLoading());
      final libraryData = await _libraryRepository.fetchLibraryDetails(userId);
      emit(LibraryLoaded(libraryData));
    } catch (e) {
      emit(LibraryFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
