import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/browser/page.dart';
import 'package:dragonfly/src/screens/browser/errors/cant_find_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserCubit, BrowserState>(
      builder: (context, state) {
        final tab = state.currentTag();
        final currentTabId = state.currentTabId;

        if (tab == null) {
          return Center(
            child: Text("Enter an URL"),
          );
        }

        return switch (tab) {
          Success() => Text("Success"),
          Loading() => Center(
              child: CircularProgressIndicator(),
            ),
          ErrorResponse m => switch (m.error) {
              NavigationError.cantFindPage =>
                ServerNotFoundPage(tab: m, tabId: currentTabId),
            },
        };
      },
    );
  }
}
