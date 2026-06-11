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
    print('LibraryCubit: Initializing...');
    
    // Check initial user immediately
    final currentUser = AuthenticationRepository.instance.currentUser;
    if (currentUser != null) {
      print('LibraryCubit: Found current user immediately: ${currentUser.uid}');
      fetchLibraryRecord(currentUser.uid);
    } else {
      print('LibraryCubit: No user found immediately.');
    }

    // Also listen to future changes
    _authSubscription = AuthenticationRepository.instance.authStateChanges.listen((user) {
      if (user != null) {
        print('LibraryCubit: Auth state changed. User UID: ${user.uid}');
        fetchLibraryRecord(user.uid);
      } else {
        print('LibraryCubit: Auth state changed to null.');
        emit(LibraryInitial());
      }
    });
  }

  Future<void> fetchLibraryRecord(String userId) async {
    try {
      print('LibraryCubit: Fetching library doc for UID: $userId');
      emit(LibraryLoading());
      
      var libraryData = await _libraryRepository.fetchLibraryDetails(userId);
      
      // If the library record doesn't exist in Firestore, auto-seed it
      if (libraryData.id.isEmpty) {
        print('LibraryCubit: Library record does not exist. Auto-seeding default library info...');
        final currentUser = AuthenticationRepository.instance.currentUser;
        
        libraryData = LibraryModel(
          id: userId,
          libraryName: 'EdoxLibrary',
          ownerName: 'Admin',
          email: currentUser?.email ?? 'admin@edoxlibrary.com',
          mobile: '9876543210',
          address: 'Not provided',
          logo: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _libraryRepository.saveLibraryRecord(libraryData);
        print('LibraryCubit: Successfully seeded default library info in Firestore.');
      } else {
        print('LibraryCubit: Library document found. Data: ${libraryData.toJson()}');
      }
      
      emit(LibraryLoaded(libraryData));
    } catch (e, stackTrace) {
      print('LibraryCubit: Error fetching library details: $e');
      print(stackTrace);
      emit(LibraryFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
