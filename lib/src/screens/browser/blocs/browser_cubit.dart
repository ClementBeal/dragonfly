import 'package:dragonfly/browser/page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserState {
  final List<Response> tabs;
  final int currentTabId;

  BrowserState({required this.tabs, required this.currentTabId});

  Response? currentTag() {
    if (currentTabId < 0) {
      return null;
    }

    return tabs[currentTabId];
  }
}

class BrowserCubit extends Cubit<BrowserState> {
  BrowserCubit() : super(BrowserState(tabs: [], currentTabId: -1));

  Future<void> visitUri(Uri uri) async {
    if (state.currentTabId < 0) {
      emit(BrowserState(tabs: [Loading(uri: uri)], currentTabId: 0));
    }

    final response = await getHttp(uri);
    final newTabs = [...state.tabs];
    newTabs[state.currentTabId] = response;

    emit(
      BrowserState(
        tabs: newTabs,
        currentTabId: state.currentTabId,
      ),
    );
  }

  Future<void> retry(int tabId) async {
    final tab = state.tabs[tabId];

    emit(BrowserState(tabs: [Loading(uri: tab.uri)], currentTabId: 0));

    final response = await getHttp(tab.uri);
    final newTabs = [...state.tabs];
    newTabs[state.currentTabId] = response;

    emit(BrowserState(
      tabs: newTabs,
      currentTabId: state.currentTabId,
    ));
  }
}
