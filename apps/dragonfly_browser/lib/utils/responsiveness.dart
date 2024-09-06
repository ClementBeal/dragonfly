import 'package:flutter/material.dart';

enum ScreenSize { small, medium, big, huge }

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;

  if (width < 450) {
    return ScreenSize.small;
  } else if (width < 768) {
    return ScreenSize.medium;
  } else if (width < 1024) {
    return ScreenSize.big;
  } else {
    return ScreenSize.huge;
  }
}
