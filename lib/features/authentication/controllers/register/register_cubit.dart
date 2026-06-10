import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/library/library_repository.dart';
import 'package:edox_library/features/authentication/models/library_model.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String error;
  RegisterFailure(this.error);
}

class RegisterCubit extends Cubit<RegisterState> {
  final _authRepo = AuthenticationRepository.instance;
  final _libraryRepo = LibraryRepository.instance;

  RegisterCubit() : super(RegisterInitial());

  Future<void> register({
    required String email,
    required String password,
    required String libraryName,
    required String ownerName,
    required String mobile,
    required String address,
  }) async {
    emit(RegisterLoading());
    try {
      final userCredential = await _authRepo.registerWithEmailAndPassword(email, password);
      
      final newLibrary = LibraryModel(
        id: userCredential.user!.uid,
        libraryName: libraryName,
        ownerName: ownerName,
        email: email,
        mobile: mobile,
        address: address,
        logo: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _libraryRepo.saveLibraryRecord(newLibrary);
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
