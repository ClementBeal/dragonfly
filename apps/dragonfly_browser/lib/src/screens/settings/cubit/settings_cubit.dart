import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(
          SettingsState(
            themeMode: ThemeMode.system,
            mainColor: Colors.green,
          ),
        );

  void setThemeMode(ThemeMode themeMode) {
    emit(
      state.copyWith(
        themeMode: themeMode,
      ),
    );
  }

  void setDownloadLocation(String location) {
    emit(
      state.copyWith(
        downloadLocation: location,
      ),
    );
  }

  void setMainColor(Color color) {
    emit(state.copyWith(mainColor: color));
  }
}
