import 'package:get_storage/get_storage.dart';

/// A local key-value storage utility powered by [GetStorage].
///
/// Call [XLocalStorage.init] once during app startup before reading or writing.
///
/// ```dart
/// await XLocalStorage.init();
/// await XLocalStorage.write(XLocalStorage.keyRememberMe, true);
/// final remember = XLocalStorage.read<bool>(XLocalStorage.keyRememberMe);
/// ```
class XLocalStorage {
  XLocalStorage._();

  // ──────────────────────────── Storage Keys ─────────────────────

  /// Whether this is the first time the app is launched.
  static const String keyIsFirstTime = 'is_first_time';

  /// Whether the "Remember Me" checkbox was checked on the login screen.
  static const String keyRememberMe = 'remember_me';

  /// The currently active library identifier.
  static const String keyLibraryId = 'library_id';

  /// The user's preferred theme mode (`light`, `dark`, `system`).
  static const String keyThemeMode = 'theme_mode';

  // ──────────────────────────── Internal ─────────────────────────

  static final GetStorage _storage = GetStorage();

  // ──────────────────────────── API ──────────────────────────────

  /// Initialises the storage engine. Must be called before any read/write.
  static Future<void> init() async {
    await GetStorage.init();
  }

  /// Reads a value of type [T] for the given [key].
  /// Returns `null` if the key does not exist.
  static T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  /// Writes [value] for the given [key]. Creates the key if it does not exist.
  static Future<void> write(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  /// Removes the entry for the given [key].
  static Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  /// Clears all stored data.
  static Future<void> clear() async {
    await _storage.erase();
  }
}
