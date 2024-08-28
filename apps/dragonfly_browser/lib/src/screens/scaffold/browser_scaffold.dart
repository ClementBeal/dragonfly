import 'dart:io';

import 'package:dragonfly/shortcuts/shortcuts.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/browser_screen.dart';
import 'package:dragonfly/src/screens/developer_tools/developer_tools_screen.dart';
import 'package:dragonfly/src/screens/favorites/favorite_bar.dart';
import 'package:dragonfly/src/screens/history/history_screen.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:dragonfly/src/screens/scaffold/widgets/tab_bar.dart';
import 'package:dragonfly/src/widgets/docking.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyT):
              NewTabIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.tab):
              SwitchTabIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyW):
              CloseTabIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyH):
              OpenHistoryIntent(),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowLeft):
              NavigationBackwardIntent(),
          LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.arrowRight):
              NavigationForwardIntent(),
          LogicalKeySet(LogicalKeyboardKey.f12): ToggleDevToolsIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            NewTabIntent: CallbackAction<NewTabIntent>(
              onInvoke: (intent) => context.read<BrowserCubit>().openNewTab(),
            ),
            SwitchTabIntent: CallbackAction<SwitchTabIntent>(
              onInvoke: (intent) =>
                  context.read<BrowserCubit>().switchToNextTab(),
            ),
            CloseTabIntent: CallbackAction<CloseTabIntent>(
              onInvoke: (intent) =>
                  context.read<BrowserCubit>().closeCurrentTab(),
            ),
            OpenHistoryIntent: CallbackAction<OpenHistoryIntent>(
              onInvoke: (intent) => showHistoryScreen(context),
            ),
            NavigationBackwardIntent: CallbackAction<NavigationBackwardIntent>(
              onInvoke: (intent) => context.read<BrowserCubit>().goBack(),
            ),
            NavigationForwardIntent: CallbackAction<NavigationForwardIntent>(
              onInvoke: (intent) => context.read<BrowserCubit>().goForward(),
            ),
            ToggleDevToolsIntent: CallbackAction<ToggleDevToolsIntent>(
              onInvoke: (intent) =>
                  context.read<BrowserInterfaceCubit>().toggleDevTools(),
            )
          },
          child: BlocBuilder<BrowserInterfaceCubit, BrowserInterfaceState>(
            builder: (context, state) => Column(
              children: [
                // top
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.topDocks
                      .map((e) => getWidgetFromRedockableInterface(e, true))
                      .toList(),
                ),
                // left center right
                Expanded(
                  child: Row(
                    children: [
                      Row(
                        children: state.leftDocks
                            .map((e) =>
                                getWidgetFromRedockableInterface(e, false))
                            .toList(),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            BrowserScreen(),
                            Align(
                              alignment: Alignment.topCenter,
                              child: DockingArea(),
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: DockingArea()),
                            Align(
                                alignment: Alignment.centerRight,
                                child: DockingArea()),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: DockingArea()),
                          ],
                        ),
                      ),
                      // right
                      Row(
                        children: state.rightDocks
                            .map((e) =>
                                getWidgetFromRedockableInterface(e, false))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                // bottom
                Column(
                  children: state.bottomDocks
                      .map((e) => getWidgetFromRedockableInterface(e, true))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getWidgetFromRedockableInterface(
      RedockableInterface e, bool isInsideColumn) {
    return switch (e) {
      RedockableInterface.devtools => const DeveloperToolsScreen(),
      RedockableInterface.tabBar => BrowserTabBar(isInsideColumn),
      RedockableInterface.searchBar => BrowserActionBar(),
      RedockableInterface.bookmarks => FavoriteTabBar(),
    };
  }
}

class BrowserActionBar extends StatelessWidget {
  const BrowserActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<BrowserCubit, Browser>(
              builder: (context, state) => IconButton(
                onPressed: (state.currentTab?.canGoBack() ?? false)
                    ? () {
                        context.read<BrowserCubit>().goBack();
                      }
                    : null,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            BlocBuilder<BrowserCubit, Browser>(
              builder: (context, state) => IconButton(
                onPressed: (state.currentTab?.canGoForward() ?? false)
                    ? () {
                        context.read<BrowserCubit>().goForward();
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<BrowserCubit>().refresh();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const Expanded(child: SearchBar()),
        const SettingsBar(),
      ],
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = "http://localhost:8088";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: BlocListener<BrowserCubit, Browser>(
        listener: (context, state) {
          _searchController.text = state.currentTab?.currentPage?.url ?? "";
        },
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          textAlignVertical: TextAlignVertical.center,
          onEditingComplete: () {
            var uri = Uri.parse(_searchController.text);

            context.read<BrowserCubit>().navigateToPage(uri.toString());
          },
          decoration: InputDecoration(
            filled: true,
            // fillColor: const Color(0xff4f4d4f),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            prefix: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.lock_open)),
              ],
            ),
            suffix: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filled(
                  onPressed: () {
                    var uri = Uri.parse(_searchController.text);

                    context.read<BrowserCubit>().navigateToPage(uri.toString());
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.star_border),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsBar extends StatelessWidget {
  const SettingsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.density_medium),
      onSelected: (String item) {
        // Handle menu item selection here
        switch (item) {
          case 'New Tab':
            context.read<BrowserCubit>().openNewTab();
            break;
          case 'Bookmarks':
            // TODO: Implement bookmarks action
            break;
          case 'History':
            showHistoryScreen(context);
            break;
          case 'Downloads':
            // TODO: Implement downloads action
            break;
          case 'Settings':
            // TODO: Implement settings action
            break;
          case 'Quit':
            exit(0);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'New Tab',
          child: Text('New Tab'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'Bookmarks',
          child: Text('Bookmarks'),
        ),
        const PopupMenuItem<String>(
          value: 'History',
          child: Text('History'),
        ),
        const PopupMenuItem<String>(
          value: 'Downloads',
          child: Text('Downloads'),
        ),
        const PopupMenuItem<String>(
          value: 'Settings',
          child: Text('Settings'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'Quit',
          child: Text('Quit'),
        ),
      ],
    );
  }
}

class WindowControlWidget extends StatefulWidget {
  const WindowControlWidget({super.key});

  @override
  State<WindowControlWidget> createState() => _WindowControlWidgetState();
}

class _WindowControlWidgetState extends State<WindowControlWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => windowManager.minimize(),
          icon: const Icon(
            Icons.minimize,
          ),
        ),
        IconButton(
          onPressed: () async {
            await (windowManager.isMaximized())
                ? windowManager.unmaximize()
                : windowManager.maximize();
          },
          icon: const Icon(
            Icons.window,
          ),
        ),
        IconButton(
          onPressed: () => exit(0),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
