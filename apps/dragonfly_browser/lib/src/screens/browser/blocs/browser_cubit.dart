import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserCubit extends Cubit<Browser> {
  BrowserCubit() : super(Browser()) {
    state.onUpdate = _onUpdate;
  }

  void _onUpdate() {
    emit(state.copyWith());
  }

  void openNewTab({String? initialUrl, bool switchTab = false}) {
    state.openNewTab(initialUrl, switchTab: switchTab);

    emit(state.copyWith());
  }

  void closeCurrentTab() {
    state.closeCurrentTab();
    emit(state.copyWith());
  }

  void switchToTab(String guid) {
    emit(state.copyWith(currentTabGuid: guid));
  }

  void navigateToPage(String url) {
    if (state.currentTab != null) {
      final updatedTab = state.currentTab;
      updatedTab?.navigateTo(url, _onUpdate);

      emit(state.copyWith());
    } else {
      state.openNewTab(url);
    }
  }

  void goBack() {
    state.currentTab?.goBack();

    emit(state.copyWith(tabs: state.tabs));
  }

  void goForward() {
    state.currentTab?.goForward();
    emit(state.copyWith(tabs: state.tabs));
  }

  void closeTab(String guid) {
    state.closeTab(guid);
    emit(state.copyWith());
  }

  void refresh() {
    state.currentTab?.refresh(_onUpdate);
  }

  void switchToNextTab() {
    final currentTab = state.currentTab;

    if (currentTab == null) {
      return;
    }

    final index = state.tabs.indexOf(currentTab);
    final nextTab = (index + 1 >= state.tabs.length)
        ? state.tabs.first
        : state.tabs[index + 1];

    emit(state.copyWith(currentTabGuid: nextTab.guid));
  }

  void togglePin(String tagId) {
    state.togglePin(tagId);

    emit(state.copyWith());
  }

  void updateTabOrder(String tabId, int newOrder) {
    state.changeTabOrder(tabId, newOrder);

    emit(state.copyWith());
  }

  void cleanNetworkTool() {
    state.currentTab?.tracker.clear();
    emit(state.copyWith());
  }
}
