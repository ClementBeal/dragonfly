part of 'settings_cubit.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String downloadLocation;
  final Color mainColor;

  SettingsState({
    required this.themeMode,
    this.downloadLocation = 'default',
    required this.mainColor,
  });

  SettingsState copyWith(
      {ThemeMode? themeMode, String? downloadLocation, Color? mainColor}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      downloadLocation: downloadLocation ?? this.downloadLocation,
      mainColor: mainColor ?? this.mainColor,
    );
  }
}
