import 'package:dragonfly/src/screens/history/history_screen.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaletteCommand {
  final String title;
  final String description;
  final Function(BuildContext context) onSelected;

  PaletteCommand(
      {required this.title,
      required this.description,
      required this.onSelected});
}

final paletteCommands = [
  PaletteCommand(
    title: "Show history",
    description: "",
    onSelected: (context) {
      showHistoryScreen(context);
    },
  ),
  PaletteCommand(
    title: "Show Network devtool",
    description: "Open the devtools on the network tab",
    onSelected: (context) {
      context.read<BrowserInterfaceCubit>().toggleDevTools();
    },
  ),
];
