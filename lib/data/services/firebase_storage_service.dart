import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import 'package:edox_library/utils/logging/logger.dart';

/// A [GetxService] that wraps [FirebaseStorage] for uploading and
/// deleting images and files in the EdoxLibrary application.
///
/// Accepts both [File] (mobile) and [Uint8List] (web) inputs.
class FirebaseStorageService extends GetxService {
  FirebaseStorageService._();
  static final FirebaseStorageService _instance = FirebaseStorageService._();
  factory FirebaseStorageService() => _instance;

  static FirebaseStorageService get instance => Get.find();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ──────────────────────────── Upload Image ─────────────────────

  /// Uploads an image to [path] and returns the download URL.
  ///
  /// [file] can be a [File] or a [Uint8List].
  Future<String> uploadImage(String path, dynamic file) async {
    try {
      XLoggerHelper.info('Uploading image → $path');
      final ref = _storage.ref(path);

      final UploadTask uploadTask;
      if (file is File) {
        uploadTask = ref.putFile(file);
      } else if (file is Uint8List) {
        uploadTask = ref.putData(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        throw ArgumentError('file must be a File or Uint8List');
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      XLoggerHelper.info('Image uploaded → $downloadUrl');
      return downloadUrl;
    } catch (e, st) {
      XLoggerHelper.error('Image upload failed: $path', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── Delete Image ────────────────────

  /// Deletes the file at [imageUrl] from Firebase Storage.
  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;
      XLoggerHelper.info('Deleting image → $imageUrl');
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      XLoggerHelper.info('Image deleted successfully');
    } catch (e, st) {
      XLoggerHelper.error('Image deletion failed: $imageUrl', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── Upload File ─────────────────────

  /// Uploads a generic file to [path] and returns the download URL.
  ///
  /// [file] can be a [File] or a [Uint8List].
  Future<String> uploadFile(String path, dynamic file) async {
    try {
      XLoggerHelper.info('Uploading file → $path');
      final ref = _storage.ref(path);

      final UploadTask uploadTask;
      if (file is File) {
        uploadTask = ref.putFile(file);
      } else if (file is Uint8List) {
        uploadTask = ref.putData(file);
      } else {
        throw ArgumentError('file must be a File or Uint8List');
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      XLoggerHelper.info('File uploaded → $downloadUrl');
      return downloadUrl;
    } catch (e, st) {
      XLoggerHelper.error('File upload failed: $path', error: e, stackTrace: st);
      rethrow;
    }
  }
}
