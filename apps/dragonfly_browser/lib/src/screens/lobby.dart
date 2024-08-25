import 'dart:io';

import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/browser/page.dart';
import 'package:dragonfly/src/screens/browser/browser_screen.dart';
import 'package:dragonfly/src/screens/history/history_screen.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_manager/window_manager.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Column(
        children: [
          BrowserTabBar(),
          BrowserActionBar(),
          Expanded(child: BrowserScreen())
        ],
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
      child: BlocBuilder<BrowserCubit, BrowserState>(
        builder: (context, state) {
          return Row(
            children: [
              // Tabs
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.tabs.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final tab = state.tabs[index];
                    final isActive = index == state.currentTabId;

                    return BrowserTab(
                      tab: tab,
                      isActive: isActive,
                      onTap: () {
                        context.read<BrowserCubit>().changeTab(index);
                      },
                      onClose: () {
                        context.read<BrowserCubit>().closeTab(index);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () => context.read<BrowserCubit>().addTab(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(Icons.add, size: 20),
                  ),
                ),
              ),
              Align(
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
    return ConstrainedBox(
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
                  switch (tab.favicon?.type) {
                    FaviconType.unknown || null => const SizedBox.shrink(),
                    FaviconType.url =>
                      Image.network(tab.favicon!.href, height: 22, width: 22),
                    FaviconType.png ||
                    FaviconType.ico ||
                    FaviconType.jpeg ||
                    FaviconType.webp ||
                    FaviconType.gif =>
                      Image.memory(tab.favicon!.decodeBase64()!),
                    FaviconType.svg =>
                      SvgPicture.memory(tab.favicon!.decodeBase64()!),
                  },
                  if (tab.currentResponse?.title != null)
                    Expanded(
                      child: Text(
                        tab.currentResponse!.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
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
            BlocBuilder<BrowserCubit, BrowserState>(
              builder: (context, state) => IconButton(
                onPressed: (state.currentTab?.canNavigatePrevious ?? false)
                    ? () {
                        context.read<BrowserCubit>().navigatePrevious();
                      }
                    : null,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            BlocBuilder<BrowserCubit, BrowserState>(
              builder: (context, state) => IconButton(
                onPressed: (state.currentTab?.canNavigateNext ?? false)
                    ? () {
                        context.read<BrowserCubit>().navigateNext();
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<BrowserCubit>().refreshCurrentTab();
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
    return BlocListener<BrowserCubit, BrowserState>(
      listener: (context, state) {
        _searchController.text =
            state.currentTab?.currentResponse?.uri.toString() ?? "no uri";
      },
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
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

                    context.read<BrowserCubit>().visitUri(uri);
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
                const Chip(label: Text("100%")),
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.star_border)),
              ],
            )),
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
            context.read<BrowserCubit>().addTab();
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
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'New Tab',
          child: Text('New Tab'),
        ),
        PopupMenuDivider(),
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
        PopupMenuDivider(),
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
