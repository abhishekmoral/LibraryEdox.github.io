import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:edox_library/firebase_options.dart';
import 'package:edox_library/app.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App());
}
