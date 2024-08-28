import 'dart:io';

import 'package:dragonfly/shortcuts/shortcuts.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/browser_screen.dart';
import 'package:dragonfly/src/screens/favorites/favorite_bar.dart';
import 'package:dragonfly/src/screens/history/history_screen.dart';
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
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IconButtonTheme(
                data: IconButtonThemeData(
                  style: ButtonStyle(
                    iconColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors
                            .grey.shade800; // Color when the icon is disabled
                      }
                      return Colors
                          .white; // Color when the icon is not disabled
                    }),
                  ),
                ),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BrowserTabBar(),
                      SizedBox(height: 50, child: BrowserActionBar()),
                      SizedBox(height: 50, child: FavoriteTabBar()),
                    ],
                  ),
                ),
              ),
              const Expanded(child: BrowserScreen())
            ],
          ),
        ),
      ),
    );
  }
}

class BrowserTabBar extends StatelessWidget {
  const BrowserTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: BlocBuilder<BrowserCubit, Browser>(
        builder: (context, state) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Row(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.tabs.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final tab = state.tabs[index];
                        final isActive = tab.guid == state.currentTabGuid;

                        return BrowserTab(
                          tab: tab,
                          isActive: isActive,
                          onTap: () {
                            context.read<BrowserCubit>().switchToTab(tab.guid);
                          },
                          onClose: () {
                            context.read<BrowserCubit>().closeTab(tab.guid);
                          },
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => context.read<BrowserCubit>().openNewTab(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Align(
                  alignment: Alignment.centerRight,
                  child: WindowControlWidget()),
            ],
          );
        },
      ),
    );
  }
}

class BrowserTab extends StatelessWidget {
  final Tab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const BrowserTab({
    super.key,
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tab.currentPage?.getTitle() ?? "",
      waitDuration: const Duration(milliseconds: 300),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250, minWidth: 100),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? Colors.blue : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  spacing: 8,
                  children: [
                    if (tab.currentPage?.status == PageStatus.loading)
                      const SizedBox.square(
                        dimension: 15,
                        child: CircularProgressIndicator(),
                      ),
                    // switch (tab.favicon?.type) {
                    // FaviconType.unknown || null => const SizedBox.shrink(),
                    // FaviconType.url =>
                    // Image.network(tab.favicon!.href, height: 22, width: 22),
                    // FaviconType.png ||
                    // FaviconType.ico ||
                    // FaviconType.jpeg ||
                    // FaviconType.webp ||
                    // FaviconType.gif =>
                    // Image.memory(tab.favicon!.decodeBase64()!),
                    // FaviconType.svg =>
                    // SvgPicture.memory(tab.favicon!.decodeBase64()!),
                    // TODO: Handle this case.
                    // Object() => throw UnimplementedError(),
                    // },
                    if (tab.currentPage != null)
                      Expanded(
                        child: Text(
                          tab.currentPage!.getTitle() ?? "No title",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),

                    // Close button
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, size: 16.0),
                      constraints: const BoxConstraints(
                        maxWidth: 16.0,
                        maxHeight: 16.0,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
    return BlocListener<BrowserCubit, Browser>(
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
          fillColor: const Color(0xff4f4d4f),
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
