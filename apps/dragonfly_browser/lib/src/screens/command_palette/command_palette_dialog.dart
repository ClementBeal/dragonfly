import 'package:flutter/material.dart';

Future<void> showCommandPalette(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => SizedBox.shrink(),
  );
}
