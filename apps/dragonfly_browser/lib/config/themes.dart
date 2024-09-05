import 'package:flutter/material.dart';

ThemeData getLightTheme(Color seedColor) {
  return ThemeData(
    colorSchemeSeed: seedColor,
    brightness: Brightness.light,
  );
}

ThemeData getDarkTheme(Color seedColor) {
  return ThemeData(
    colorSchemeSeed: seedColor,
    brightness: Brightness.dark,
  );
}
