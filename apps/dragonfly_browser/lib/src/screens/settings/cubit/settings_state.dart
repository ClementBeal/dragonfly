part of 'settings_cubit.dart';

class SettingsState {
  final ThemeMode themeMode;

  SettingsState({required this.themeMode});

  SettingsState copyWith({ThemeMode? themeMode}) {
    return SettingsState(themeMode: themeMode ?? this.themeMode);
  }
}
