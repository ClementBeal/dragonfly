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
    description: "View your browsing history.",
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
  PaletteCommand(
    title: "Open new tab",
    description: "Create a new browser tab.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Close current tab",
    description: "Close the currently active tab.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Reopen closed tab",
    description: "Reopen the last closed tab.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Bookmarks",
    description: "View your saved bookmarks.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Add bookmark",
    description: "Bookmark the current page.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Downloads",
    description: "View your downloaded files.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Find in page",
    description: "Search for text on the current page.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Share",
    description: "Share the current page.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Settings",
    description: "Adjust browser settings.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Reload page",
    description: "Refresh the current page.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Open Incognito tab",
    description: "Browse privately without saving history.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "View page source",
    description: "See the HTML source code of the current page.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Zoom in",
    description: "Increase the size of the page content.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Zoom out",
    description: "Decrease the size of the page content.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Reset zoom",
    description: "Return to the default page zoom level.",
    onSelected: (context) {},
  ),
  PaletteCommand(
    title: "Clear browsing data",
    description: "Delete browsing history, cookies, and cached data.",
    onSelected: (context) {},
  ),
];
