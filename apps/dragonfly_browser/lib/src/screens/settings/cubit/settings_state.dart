part of 'settings_cubit.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String downloadLocation;
  final Color mainColor;
  final String searchEngine;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.downloadLocation = 'default',
    this.mainColor = Colors.blue,
    this.searchEngine = 'google',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? downloadLocation,
    Color? mainColor,
    String? searchEngine,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      downloadLocation: downloadLocation ?? this.downloadLocation,
      mainColor: mainColor ?? this.mainColor,
      searchEngine: searchEngine ?? this.searchEngine,
    );
  }
}
