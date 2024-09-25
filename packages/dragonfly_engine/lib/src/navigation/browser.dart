import 'package:collection/collection.dart';
import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:dragonfly_engine/src/navigation/tab.dart';

/// Represents a web browser instance, managing tabs and navigation.
class Browser {
  /// List of tabs within the browser.
  late List<Tab> tabs;

  /// GUID of the currently active tab.
  String? currentTabGuid;

  /// Callback function triggered when the browser state is updated.
  Function()? onUpdate;

  /// Global navigation history shared across all tabs.
  NavigationHistory navigationHistory;

  /// Creates a new Browser instance.
  ///
  /// [navigationHistory] provides access to the global navigation history.
  /// [tabs] (optional) initializes the browser with a list of tabs.
  /// [currentTabGuid] (optional) sets the initially active tab.
  Browser(
    this.navigationHistory, {
    List<Tab>? tabs,
    this.currentTabGuid,
  }) {
    this.tabs = tabs ?? [];
  }

  /// Returns the currently active `Tab` object, or null if no tab is active.
  Tab? get currentTab => currentTabGuid != null
      ? tabs.firstWhere(
          (e) => e.guid == currentTabGuid,
        )
      : null;

  /// Creates a copy of the Browser instance with optional modifications.
  ///
  /// [tabs] (optional) sets the tabs for the new copy.
  /// [currentTabGuid] (optional) sets the active tab for the new copy.
  Browser copyWith({List<Tab>? tabs, String? currentTabGuid}) {
    return Browser(
      navigationHistory,
      tabs: tabs ?? this.tabs,
      currentTabGuid: currentTabGuid ?? this.currentTabGuid,
    )..onUpdate = onUpdate;
  }

  /// Opens a new tab in the browser.
  ///
  /// [initialUrl] (optional) sets the initial URL for the new tab.
  /// [switchTab] (optional) determines whether to switch to the new tab after creation (default: true).
  void openNewTab(Uri? initialUrl, {bool switchTab = true}) {
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

  /// Closes the currently active tab.
  void closeCurrentTab() {
    closeTab(currentTabGuid);
  }

  /// Closes the tab with the specified GUID.
  ///
  /// [guid] is the GUID of the tab to close.
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

  /// Switches to the tab with the specified GUID.
  ///
  /// [guid] is the GUID of the tab to switch to.
  void switchToTab(String guid) {
    currentTabGuid = guid;
  }

  /// Changes the order of a tab in the tab bar.
  ///
  /// [tabId] is the GUID of the tab to reorder.
  /// [newOrder] is the new order index for the tab.
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

  /// Toggles the pinned state of a tab.
  ///
  /// [tabId] is the GUID of the tab to toggle.
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
