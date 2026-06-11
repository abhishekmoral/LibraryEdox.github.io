import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/settings/models/settings_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final SettingsModel settings;
  SettingsLoaded(this.settings);
}

class SettingsFailure extends SettingsState {
  final String message;
  SettingsFailure(this.message);
}

class SettingsCubit extends Cubit<SettingsState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;
  String? _userId;

  SettingsCubit() : super(SettingsInitial()) {
    _init();
  }

  void _init() {
    _authSubscription = AuthenticationRepository.instance.authStateChanges.listen((user) {
      if (user != null) {
        _userId = user.uid;
        fetchSettings(user.uid);
      } else {
        _userId = null;
        emit(SettingsInitial());
      }
    });
  }

  Future<void> fetchSettings(String userId) async {
    try {
      emit(SettingsLoading());
      final doc = await _db
          .collection(XFirebaseConstants.librariesCollection)
          .doc(userId)
          .collection(XFirebaseConstants.configDocument)
          .doc(XFirebaseConstants.settingsDocument)
          .get();

      if (doc.exists) {
        emit(SettingsLoaded(SettingsModel.fromSnapshot(doc)));
      } else {
        final defaultSettings = SettingsModel.empty();
        await _db
            .collection(XFirebaseConstants.librariesCollection)
            .doc(userId)
            .collection(XFirebaseConstants.configDocument)
            .doc(XFirebaseConstants.settingsDocument)
            .set(defaultSettings.toJson());
        emit(SettingsLoaded(defaultSettings));
      }
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  Future<void> updateSettings(SettingsModel updatedSettings) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      final newSettings = updatedSettings.copyWith(updatedAt: DateTime.now());
      emit(SettingsLoaded(newSettings));

      await _db
          .collection(XFirebaseConstants.librariesCollection)
          .doc(userId)
          .collection(XFirebaseConstants.configDocument)
          .doc(XFirebaseConstants.settingsDocument)
          .set(newSettings.toJson());
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  Future<void> toggleWhatsApp(bool enabled) async {
    if (state is SettingsLoaded) {
      final current = (state as SettingsLoaded).settings;
      await updateSettings(current.copyWith(whatsappEnabled: enabled));
    }
  }

  Future<void> toggleSMS(bool enabled) async {
    if (state is SettingsLoaded) {
      final current = (state as SettingsLoaded).settings;
      await updateSettings(current.copyWith(smsEnabled: enabled));
    }
  }

  Future<void> updateReminderDays(List<int> days) async {
    if (state is SettingsLoaded) {
      final current = (state as SettingsLoaded).settings;
      await updateSettings(current.copyWith(reminderDays: days));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
