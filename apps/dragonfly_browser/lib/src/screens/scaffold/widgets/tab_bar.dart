import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:dragonfly/src/widgets/docking.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserTabBar extends StatelessWidget {
  const BrowserTabBar(this.isInsideColumn, {super.key});

  final bool isInsideColumn;

  @override
  Widget build(BuildContext context) {
    return RedockableWidget(
      interface: RedockableInterface.tabBar,
      child: BlocBuilder<BrowserCubit, Browser>(
        builder: (context, state) {
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
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.tabs.length,
                        itemBuilder: (context, index) {
                          final tab = state.tabs[index];
                          final isActive = tab.guid == state.currentTabGuid;

                          return VerticalTab(
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
                          );
                        },
                      ),
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
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: state.tabs.length,
                      itemBuilder: (context, index) {
                        final tab = state.tabs[index];
                        final isActive = tab.guid == state.currentTabGuid;

                        return FlatTab(
                          tab: tab,
                          isActive: isActive,
                          onTap: () {
                            context.read<BrowserCubit>().switchToTab(tab.guid);
                          },
                          onClose: () {
                            context.read<BrowserCubit>().closeTab(tab.guid);
                          },
                          isVertical: isInsideColumn,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton.filled(
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
                ],
              ),
            );
          }
        },
      ),
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
                maxWidth: 120,
              ),
              child: Row(
                mainAxisSize: isVertical ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (tab.currentPage?.status == PageStatus.loading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: SizedBox.square(
                        dimension: 15,
                        child: CircularProgressIndicator(),
                      ),
                    ),
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
          child: Card(
            color: isActive
                ? Colors.blue.shade700.withOpacity(0.4)
                : Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
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
                      const Icon(Icons.language),
                    // Expanded(
                    //   child: Text(
                    //     tab.currentPage?.getTitle() ?? "No title",
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontWeight:
                    //           isActive ? FontWeight.bold : FontWeight.normal,
                    //     ),
                    //   ),
                    // ),
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
