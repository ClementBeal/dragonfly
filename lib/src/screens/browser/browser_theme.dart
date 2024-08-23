import 'package:dragonfly/browser/css/cssom_builder.dart';
import 'package:flutter/material.dart';

class CSSOMProvider extends InheritedWidget {
  final CSSOM cssom;

  const CSSOMProvider({
    super.key,
    required this.cssom,
    required super.child,
  });

  static CSSOMProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CSSOMProvider>();
  }

  @override
  bool updateShouldNotify(CSSOMProvider oldWidget) {
    return cssom != oldWidget.cssom;
  }
}
