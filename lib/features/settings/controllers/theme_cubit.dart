import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edox_library/utils/local_storage/storage_utility.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeStr = XLocalStorage.read<String>(XLocalStorage.keyThemeMode);
    if (themeStr == 'dark') {
      emit(ThemeMode.dark);
    } else if (themeStr == 'light') {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.system);
    }
  }

  void toggleTheme(bool isDark) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    XLocalStorage.write(XLocalStorage.keyThemeMode, isDark ? 'dark' : 'light');
    emit(newMode);
  }
}
