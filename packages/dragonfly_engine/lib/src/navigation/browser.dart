import 'package:collection/collection.dart';
import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:dragonfly_engine/src/navigation/tab.dart';

class Browser {
  late List<Tab> tabs;
  String? currentTabGuid;
  Function()? onUpdate;
  NavigationHistory navigationHistory;

  Browser(
    this.navigationHistory, {
    List<Tab>? tabs,
    this.currentTabGuid,
  }) {
    this.tabs = tabs ?? [];
  }

  Tab? get currentTab => currentTabGuid != null
      ? tabs.firstWhere(
          (e) => e.guid == currentTabGuid,
        )
      : null;

  Browser copyWith({List<Tab>? tabs, String? currentTabGuid}) {
    return Browser(
      navigationHistory,
      tabs: tabs ?? this.tabs,
      currentTabGuid: currentTabGuid ?? this.currentTabGuid,
    )..onUpdate = onUpdate;
  }

  void openNewTab(String? initialUrl, {bool switchTab = true}) {
    final lastOrder =
        tabs.where((e) => !e.isPinned).map((e) => e.order).maxOrNull;
    final newTab = Tab(
      order: (lastOrder ?? -1) + 1,
      navigationHistory: navigationHistory,
    );

    if (initialUrl != null) {
      newTab.navigateTo(initialUrl, onUpdate ?? () {});
    }

    tabs.add(newTab);

    if (switchTab) {
      switchToTab(newTab.guid);
    }
  }

  void closeCurrentTab() {
    closeTab(currentTabGuid);
  }

  void closeTab(String? guid) {
    if (currentTabGuid != null) {
      final tabId = tabs.indexWhere(
        (e) => e.guid == currentTabGuid,
      );
      tabs.removeWhere(
        (e) => e.guid == currentTabGuid,
      );

      currentTabGuid = tabs.isEmpty ? null : tabs[tabId - 1].guid;
    }
  }

  void switchToTab(String guid) {
    currentTabGuid = guid;
  }

  void changeTabOrder(String tabId, int newOrder) {
    final tab = tabs.firstWhereOrNull((e) => e.guid == tabId);

    if (tab == null) return;

    // move right
    if (tab.order < newOrder) {
      tabs
          .where(
              (e) => !e.isPinned && tab.order < e.order && e.order <= newOrder)
          .forEach(
            (e) => e.order--,
          );
      tab.order = newOrder;
    }
    // move left
    else {
      tabs
          .where(
              (e) => !e.isPinned && newOrder <= e.order && e.order < tab.order)
          .forEach(
            (e) => e.order++,
          );
      tab.order = newOrder;
    }
  }

  void togglePin(String tabId) {
    final tab = tabs.firstWhereOrNull((e) => e.guid == tabId);

    if (tab != null) {
      final oldOrder = tab.order;
      final maxPinOrder =
          (tabs.where((e) => e.isPinned).map((e) => e.order).maxOrNull ?? -1) +
              1;
      tab.togglePin();

      if (tab.isPinned) {
        tab.order = maxPinOrder;

        tabs.where((e) => !e.isPinned && e.order >= oldOrder).forEach(
              (element) => element.order--,
            );
      } else {
        tab.order = -1;
        tabs.where((e) => !e.isPinned).forEach(
              (element) => element.order++,
            );
      }
    }
  }
}
