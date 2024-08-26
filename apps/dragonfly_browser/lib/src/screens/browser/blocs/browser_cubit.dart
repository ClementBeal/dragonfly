import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserCubit extends Cubit<Browser> {
  BrowserCubit() : super(Browser()) {
    state.onUpdate = _onUpdate;
  }

  void _onUpdate() {
    emit(state.copyWith());
  }

  void openNewTab({String? initialUrl}) {
    state.openNewTab(initialUrl);

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

  void refresh({int? tabId}) {}

  // Future<void> _loadLinks(List<LinkNode> links, int tabId) async {
  //   final tab = state.tabs[tabId];

  //   for (var link in links) {
  //     if (link.attributes["rel"] == "stylesheet") {
  //       final href = link.attributes["href"]!;

  //       String? fixedUrl;

  //       // if (href)

  //       final theme =
  //           await getCSS(tab.currentResponse!.uri.replace(path: href));

  //       (state.tabs[tabId].currentResponse as Success).theme = theme;
  //       emit(state.copyWith(tabs: state.tabs));
  //     }
  //   }
  // }

  // void addTabAndViewSourceCode(Uri uri, String sourceCode) {
  //   final newTabs = [
  //     ...state.tabs,
  //     Tab(
  //       history: [
  //         Success(
  //           uri: uri,
  //           favicon: null,
  //           title: uri.replace(scheme: "").toString(),
  //           content: Tree(UnkownNode()),
  //           sourceCode: sourceCode,
  //         )
  //       ],
  //     )
  //   ];

  //   emit(state.copyWith(
  //     tabs: newTabs,
  //     currentTabId: newTabs.length - 1,
  //   ));
  // }
}
