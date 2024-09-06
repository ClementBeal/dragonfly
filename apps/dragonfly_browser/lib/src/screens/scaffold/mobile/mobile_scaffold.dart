import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/browser_screen.dart';
import 'package:dragonfly/src/screens/scaffold/browser_scaffold.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MobileScaffold extends StatelessWidget {
  const MobileScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: BrowserScreen()),
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
        Expanded(
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
        SettingsBar(),
      ],
    );
  }
}

Future<void> showMobileTabs(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    constraints: BoxConstraints.expand(),
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    builder: (context) => Column(
      children: [
        BlocBuilder<BrowserCubit, Browser>(
          builder: (context, state) => Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: state.tabs.length,
              itemBuilder: (context, index) {
                final tab = state.tabs[index];

                return Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
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
                          child: ClipRect(
                            child: RenderPageWidget(
                              page: tab.currentPage,
                              tab: tab,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}
