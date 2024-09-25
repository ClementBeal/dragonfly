import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dragonfly/shortcuts/shortcuts.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/browser_screen.dart';
import 'package:dragonfly/src/screens/command_palette/command_palette_dialog.dart';
import 'package:dragonfly/src/screens/history/history_screen.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:dragonfly/src/screens/scaffold/mobile/mobile_scaffold.dart';
import 'package:dragonfly/src/screens/settings/settings_screen.dart';
import 'package:dragonfly/src/widgets/docking.dart';
import 'package:dragonfly/utils/extensions/list.dart';
import 'package:dragonfly/utils/responsiveness.dart';
import 'package:dragonfly/utils/url_detection.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
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
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.alt,
              LogicalKeyboardKey.keyP): OpenCommandPaletteIntent(),
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
            ),
            OpenCommandPaletteIntent: CallbackAction<OpenCommandPaletteIntent>(
              onInvoke: (intent) => showCommandPalette(context),
            ),
          },
          child: Builder(builder: (context) {
            return switch (getScreenSize(context)) {
              ScreenSize.small || ScreenSize.medium => const MobileScaffold(),
              ScreenSize.big || ScreenSize.huge => const DesktopScaffold(),
            };
          }),
        ),
      ),
    );
  }
}

class DesktopScaffold extends StatelessWidget {
  const DesktopScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserInterfaceCubit, BrowserInterfaceState>(
      builder: (context, state) {
        return Column(
          children: [
            // top
            Column(
              mainAxisSize: MainAxisSize.min,
              children: state.topDocks
                  .mapIndexed<Widget>(
                    (i, e) {
                      return RedockableWidget(
                        position: i,
                        interface: e,
                        dock: Dock.top,
                        child: getWidgetFromRedockableInterface(e, true),
                      );
                    },
                  )
                  .addAfterEach(
                    (i) => DockingArea(
                      isInsideColumn: true,
                      dock: Dock.top,
                      position: i,
                    ),
                  )
                  .toList(),
            ),
            // left center right
            Expanded(
              child: Row(
                children: [
                  Row(
                    children: state.leftDocks
                        .mapIndexed<Widget>(
                          (i, e) => RedockableWidget(
                            position: i,
                            interface: e,
                            dock: Dock.left,
                            child: getWidgetFromRedockableInterface(e, false),
                          ),
                        )
                        .addAfterEach(
                          (i) => DockingArea(
                            isInsideColumn: false,
                            dock: Dock.left,
                            position: i,
                          ),
                        )
                        .toList(),
                  ),
                  const Expanded(
                    child: BrowserScreen(),
                  ),
                  // right
                  Row(
                      children: state.rightDocks
                          .mapIndexed<Widget>(
                            (i, e) => RedockableWidget(
                              position: i,
                              interface: e,
                              dock: Dock.right,
                              child: getWidgetFromRedockableInterface(e, false),
                            ),
                          )
                          .addAfterEach(
                            (i) => DockingArea(
                              isInsideColumn: false,
                              dock: Dock.right,
                              position: i,
                            ),
                          )
                          .toList()),
                ],
              ),
            ),
            // bottom
            Column(
              children: state.bottomDocks
                  .mapIndexed<Widget>((i, e) => RedockableWidget(
                      position: i,
                      interface: e,
                      dock: Dock.bottom,
                      child: getWidgetFromRedockableInterface(e, true)))
                  .addAfterEach(
                    (i) => DockingArea(
                      isInsideColumn: true,
                      dock: Dock.bottom,
                      position: i,
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
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
        const Expanded(child: BrowserSearchBar()),
        const SettingsBar(),
      ],
    );
  }
}

class BrowserSearchBar extends StatefulWidget {
  const BrowserSearchBar({
    super.key,
    this.isMobile = false,
  });

  final bool isMobile;

  @override
  State<BrowserSearchBar> createState() => _BrowserSearchBarState();
}

class _BrowserSearchBarState extends State<BrowserSearchBar> {
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
            final formattedUri = detectUrl(_searchController.text);

            context
                .read<BrowserCubit>()
                .navigateToPage(formattedUri.toString());
          },
          decoration: InputDecoration(
            filled: true,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            prefix: (widget.isMobile)
                ? null
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.lock_open)),
                    ],
                  ),
            suffix: (widget.isMobile)
                ? null
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                        onPressed: () {
                          var uri = Uri.parse(_searchController.text);

                          context
                              .read<BrowserCubit>()
                              .navigateToPage(uri.toString());
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
      icon: const Icon(Icons.more_vert),
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
            showSettingsScreen(context);
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
            if (await windowManager.isMaximized()) {
              windowManager.setSize(const Size(400, 820));
              await windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
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
