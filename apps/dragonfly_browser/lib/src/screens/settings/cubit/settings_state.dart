part of 'settings_cubit.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String downloadLocation;

  SettingsState({required this.themeMode, this.downloadLocation = 'default'});

  SettingsState copyWith({ThemeMode? themeMode, String? downloadLocation}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      downloadLocation: downloadLocation ?? this.downloadLocation,
    );
  }
}
