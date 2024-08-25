import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:dragonfly/browser/dom/html_node.dart';
import 'package:dragonfly/browser/dom_builder.dart';
import 'package:dragonfly/browser/page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserState {
  final List<Tab> tabs;
  final int currentTabId;

  BrowserState({required this.tabs, required this.currentTabId});

  BrowserState copyWith({
    List<Tab>? tabs,
    int? currentTabId,
  }) {
    return BrowserState(
      tabs: tabs ?? this.tabs,
      currentTabId: currentTabId ?? this.currentTabId,
    );
  }

  Tab? get currentTab {
    if (currentTabId < 0 || currentTabId >= tabs.length) {
      return null;
    }

    return tabs[currentTabId];
  }
}

class BrowserCubit extends Cubit<BrowserState> {
  BrowserCubit() : super(BrowserState(tabs: [], currentTabId: -1));

  Future<void> visitUri(Uri uri) async {
    if (state.currentTabId < 0) {
      emit(
        BrowserState(
          tabs: [
            Tab(
              history: [
                Empty(uri: Uri()),
                Loading(uri: uri),
              ],
            ),
          ],
          currentTabId: 0,
        ),
      );
    }

    if (uri.scheme == "file") {
      final r = FileSuccess(
        uri: uri,
        title: p.basename(uri.toFilePath()),
      );

      final newTabs = [...state.tabs];

      newTabs[state.currentTabId].addPage(r);

      emit(state.copyWith(tabs: newTabs));

      return;
    }

    final response = await getHttp(uri);
    final newTabs = [...state.tabs];

    if (response is Success) {
      final linkNodes = response.content
          .findSubtreesOfType<LinkNode>(response.content)
          .map((e) => e.data)
          .cast<LinkNode>()
          .toList();

      _loadLinks(linkNodes, state.currentTabId);
    }

    newTabs[state.currentTabId].addPage(response);

    emit(state.copyWith(tabs: newTabs));
  }

  Future<void> retry(int tabId) async {
    final tab = state.tabs[tabId];

    final newTabs = [...state.tabs];
    newTabs[tabId].refresh();
    emit(state.copyWith(tabs: newTabs)); // Update UI immediately with loading

    final response = await getHttp(tab.history.last.uri);
    newTabs[tabId].setLastPage(response);

    emit(state.copyWith(tabs: newTabs));
  }

  Future<void> refreshCurrentTab() async {
    if (state.currentTabId >= 0) {
      await retry(state.currentTabId);
    }
  }

  void addTab() {
    final newTabs = [
      ...state.tabs,
      Tab(
        history: [Empty(uri: Uri())],
      )
    ];

    emit(state.copyWith(
      tabs: newTabs,
      currentTabId: newTabs.length - 1,
    ));
  }

  void changeTab(int index) {
    if (index >= 0 && index < state.tabs.length) {
      emit(state.copyWith(currentTabId: index));
    }
  }

  void closeTab(int index) {
    if (index < 0 || index >= state.tabs.length) return;

    final newTabs = [...state.tabs]..removeAt(index);
    int newCurrentTabId = state.currentTabId;

    // Adjust currentTabId if the closed tab was the active one
    if (index == state.currentTabId) {
      newCurrentTabId = newTabs.isEmpty ? -1 : 0;
    } else if (newCurrentTabId > index) {
      newCurrentTabId--;
    }

    emit(state.copyWith(
      tabs: newTabs,
      currentTabId: newCurrentTabId,
    ));
  }

  void addTabWithUri(Uri uri) {
    final newTabs = [
      ...state.tabs,
      Tab(
        history: [Loading(uri: uri)],
      )
    ];

    emit(state.copyWith(
      tabs: newTabs,
      currentTabId: newTabs.length - 1,
    ));
  }

  void navigatePrevious() {
    if (state.currentTab == null) {
      return;
    }

    if (state.currentTab!.canNavigatePrevious) {
      state.currentTab!.previousPage();
      refreshCurrentTab();
    }
  }

  void navigateNext() {
    if (state.currentTab == null) {
      return;
    }

    if (state.currentTab!.canNavigateNext) {
      state.currentTab!.nextPage();
      refreshCurrentTab();
    }
  }

  Future<void> _loadLinks(List<LinkNode> links, int tabId) async {
    final tab = state.tabs[tabId];

    for (var link in links) {
      if (link.attributes["rel"] == "stylesheet") {
        final href = link.attributes["href"]!;
        final theme =
            await getCSS(tab.currentResponse!.uri.replace(path: href));

        (state.tabs[tabId].currentResponse as Success).theme = theme;
        emit(state.copyWith(tabs: state.tabs));
      }
    }
  }

  void addTabAndViewSourceCode(Uri uri, String sourceCode) {
    final newTabs = [
      ...state.tabs,
      Tab(
        history: [
          Success(
            uri: uri,
            favicon: null,
            title: uri.replace(scheme: "").toString(),
            content: Tree(UnkownNode()),
            sourceCode: sourceCode,
          )
        ],
      )
    ];

    emit(state.copyWith(
      tabs: newTabs,
      currentTabId: newTabs.length - 1,
    ));
  }
}
