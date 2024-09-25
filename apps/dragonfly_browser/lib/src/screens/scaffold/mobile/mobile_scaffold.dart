import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/browser_screen.dart';
import 'package:dragonfly/src/screens/scaffold/browser_scaffold.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MobileScaffold extends StatelessWidget {
  const MobileScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: BrowserScreen(),
        ),
        SizedBox(
          height: 40,
          child: MobileSearchBar(),
        ),
      ],
    );
  }
}

class MobileSearchBar extends StatelessWidget {
  const MobileSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: BrowserSearchBar(isMobile: true),
        ),
        BlocBuilder<BrowserCubit, Browser>(
          builder: (context, state) => TextButton(
            onPressed: () {
              showMobileTabs(context);
            },
            child: Text(
              state.tabs.length.toString(),
            ),
          ),
        ),
        const SettingsBar(),
      ],
    );
  }
}

Future<void> showMobileTabs(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    constraints: const BoxConstraints.expand(),
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    builder: (context) => Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          context.read<BrowserCubit>().openNewTab(
                switchTab: true,
              );
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<BrowserCubit, Browser>(
            builder: (context, state) => Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: state.tabs.length,
                itemBuilder: (context, index) {
                  final tab = state.tabs[index];

                  return GestureDetector(
                    onTap: () {
                      context.read<BrowserCubit>().switchToTab(tab.guid);
                    },
                    child: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        side: (state.currentTab == tab)
                            ? BorderSide(
                                width: 2,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                tab.currentPage?.getTitle() ?? "",
                              ),
                            ),
                            Expanded(
                              child: FittedBox(
                                child: RenderPageWidget(
                                  page: tab.currentPage,
                                  tab: tab,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
