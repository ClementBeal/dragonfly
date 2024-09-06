import 'package:collection/collection.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/scaffold/widgets/favicon_icon.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserTabBar extends StatelessWidget {
  const BrowserTabBar(this.isInsideColumn, {super.key});

  final bool isInsideColumn;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserCubit, Browser>(
      builder: (context, state) {
        final sortedTabs = state.tabs.sorted((a, b) {
          if (a.isPinned) return -1;
          if (b.isPinned) return 1;

          return a.order.compareTo(b.order);
        });

        // Use a column if isVertical is true, otherwise use a row.
        if (!isInsideColumn) {
          return SizedBox(
            width: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: IconButton(
                      onPressed: () =>
                          context.read<BrowserCubit>().openNewTab(),
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                    ),
                  ),
                  const Divider(
                    indent: 8,
                    endIndent: 8,
                  ),
                  Expanded(
                    child: ReorderableTabListView(
                        scrollDirection: Axis.vertical,
                        isInsideColumn: false,
                        sortedTabs: sortedTabs,
                        builder: (tab, isActive) => VerticalTab(
                              tab: tab,
                              isActive: isActive,
                              onTap: () {
                                context
                                    .read<BrowserCubit>()
                                    .switchToTab(tab.guid);
                              },
                              onClose: () {
                                context.read<BrowserCubit>().closeTab(tab.guid);
                              },
                              isVertical: isInsideColumn,
                            )),
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: ReorderableTabListView(
                    scrollDirection: Axis.horizontal,
                    sortedTabs: sortedTabs,
                    isInsideColumn: true,
                    builder: (tab, isActive) => FlatTab(
                      tab: tab,
                      isActive: isActive,
                      onTap: () {
                        context.read<BrowserCubit>().switchToTab(tab.guid);
                      },
                      onClose: () {
                        context.read<BrowserCubit>().closeTab(tab.guid);
                      },
                      isVertical: isInsideColumn,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton.filled(
                    onPressed: () => context.read<BrowserCubit>().openNewTab(),
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class FlatTab extends StatelessWidget {
  final Tab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final bool isVertical;

  const FlatTab({
    super.key,
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
    required this.isVertical,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tab.currentPage?.getTitle() ?? "No title",
      waitDuration: const Duration(milliseconds: 300),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: Durations.short3,
            width: isVertical ? null : 150, // Adjust width for vertical layout
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.blue.shade700.withOpacity(0.4)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: isActive ? Colors.blue : Colors.transparent,
                  width: 2.0,
                ),
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 80,
                maxWidth: 160,
              ),
              child: Row(
                spacing: 8,
                mainAxisSize: isVertical ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (tab.isPinned) const Icon(Icons.lock),
                  if (tab.currentPage?.status == PageStatus.loading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: SizedBox.square(
                        dimension: 15,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (tab.currentPage is HtmlPage)
                    BrowserImageRender((tab.currentPage as HtmlPage).favicon),
                  Expanded(
                    child: Text(
                      tab.currentPage?.getTitle() ?? "No title",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
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

class VerticalTab extends StatelessWidget {
  const VerticalTab(
      {super.key,
      required this.tab,
      required this.isActive,
      required this.onTap,
      required this.onClose,
      required this.isVertical});

  final Tab tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tab.currentPage?.getTitle() ?? "No title",
      waitDuration: const Duration(milliseconds: 300),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 1,
            child: Card(
              color: isActive
                  ? Colors.blue.shade700.withOpacity(0.4)
                  : Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (tab.currentPage?.status == PageStatus.loading)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: SizedBox.square(
                                dimension: 15,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            BrowserImageRender(
                              (tab.currentPage as HtmlPage?)?.favicon,
                              onEmpty: () => const Icon(Icons.language),
                            ),
                        ],
                      ),
                    ),
                    if (tab.isPinned)
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.lock,
                          size: 12,
                        ),
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

void showTabMenu(BuildContext context, Tab tab, details) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      details.globalPosition.dx,
      details.globalPosition.dy,
      details.globalPosition.dx,
      details.globalPosition.dy,
    ),
    items: [
      PopupMenuItem(
        value: 'newTab',
        child: const Text('New Tab'),
        onTap: () => context.read<BrowserCubit>().openNewTab(switchTab: true),
      ),
      PopupMenuItem(
        value: 'refresh',
        child: const Text('Refresh'),
        onTap: () => context.read<BrowserCubit>().refresh(),
      ),
      PopupMenuItem(
        value: 'duplicate',
        child: const Text('Duplicate'),
        onTap: () {},
      ),
      PopupMenuItem(
        value: 'pin',
        child: const Text('Pin'),
        onTap: () => context.read<BrowserCubit>().togglePin(tab.guid),
      ),
      PopupMenuItem(
        value: 'close',
        child: const Text('Close'),
        onTap: () {
          context.read<BrowserCubit>().closeTab(tab.guid);
        },
      ),
    ],
  );
}

class ReorderableTabListView extends StatelessWidget {
  final List<Tab> sortedTabs; // Your sorted tab list
  final bool isInsideColumn;
  final Widget Function(Tab tab, bool isActive) builder;
  final Axis scrollDirection;

  const ReorderableTabListView({
    required this.sortedTabs,
    required this.isInsideColumn,
    required this.builder,
    super.key,
    required this.scrollDirection,
  });

  @override
  Widget build(BuildContext context) {
    final pinnedTabs = sortedTabs.where((tab) => tab.isPinned).sorted(
          (a, b) => a.order.compareTo(b.order),
        );
    final nonPinnedTabs = sortedTabs.where((tab) => !tab.isPinned).sorted(
          (a, b) => a.order.compareTo(b.order),
        );

    return ReorderableListView(
      scrollDirection: scrollDirection,
      buildDefaultDragHandles: false,
      header: ListView.builder(
        scrollDirection: scrollDirection,
        shrinkWrap: true,
        itemCount: pinnedTabs.length,
        itemBuilder: (context, index) {
          final tab = pinnedTabs[index];

          final isActive =
              tab.guid == context.read<BrowserCubit>().state.currentTabGuid;

          return GestureDetector(
            onSecondaryTapDown: (details) {
              showTabMenu(context, tab, details);
            },
            child: builder(tab, isActive),
          );
        },
      ),
      onReorder: (int oldIndex, int newIndex) {
        context.read<BrowserCubit>().updateTabOrder(
              sortedTabs[oldIndex].guid,
              (newIndex > oldIndex) ? newIndex - 1 : newIndex,
            );
      },
      children: nonPinnedTabs.mapIndexed((i, tab) {
        final isActive =
            tab.guid == context.read<BrowserCubit>().state.currentTabGuid;

        return ReorderableDragStartListener(
          key: ValueKey(tab.guid),
          index: i,
          child: GestureDetector(
            onSecondaryTapDown: (details) {
              showTabMenu(context, tab, details);
            },
            child: builder(tab, isActive),
          ),
        );
      }).toList(),
    );
  }
}
