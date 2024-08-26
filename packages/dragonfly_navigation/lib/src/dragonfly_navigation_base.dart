import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DomBuilder {
  static Document parse(String html) {
    return HtmlParser(html).parse();
  }
}

enum PageStatus { loading, error, success }

class Page {
  late final String guid;
  final String url;
  final Document? document;
  final PageStatus status;

  Page(
      {required this.url,
      required this.document,
      required this.status,
      String? guid}) {
    this.guid = guid ?? Uuid().v4();
  }

  Page copyWith({Document? document, PageStatus? status}) {
    return Page(
      url: url,
      guid: guid,
      document: document ?? this.document,
      status: status ?? this.status,
    );
  }
}

class Tab {
  late final String guid;
  final List<Page> _history = [];
  int _currentIndex = -1;

  Tab() {
    guid = Uuid().v4();
  }

  Page? get currentPage => _currentIndex >= 0 ? _history[_currentIndex] : null;

  Future<void> navigateTo(String url, Function() onNavigationDone) async {
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    _history.add(
      Page(
        document: null,
        status: PageStatus.loading,
        url: url,
      ),
    );

    final document = await getHttp(Uri.parse(url));

    _history.last = Page(
      document: document,
      status: (document != null) ? PageStatus.success : PageStatus.error,
      url: url,
    );

    print(_history);
    _currentIndex++;
    print(_currentIndex);
    print(_history.last.document?.outerHtml ?? "lol");
    print(_history.last.status);
  }

  void goBack() {
    if (canGoBack()) {
      _currentIndex--;
    }
  }

  bool canGoBack() => _currentIndex > 0;
  bool canGoForward() => _currentIndex < _history.length - 1;

  void goForward() {
    if (canGoForward()) {
      _currentIndex++;
    }
  }
}

class Browser {
  late List<Tab> tabs;
  String? currentTabGuid;
  Function()? onUpdate;

  Browser({List<Tab>? tabs, this.currentTabGuid}) {
    this.tabs = tabs ?? [];
  }

  Tab? get currentTab => currentTabGuid != null
      ? tabs.firstWhere(
          (e) => e.guid == currentTabGuid,
        )
      : null;

  Browser copyWith({List<Tab>? tabs, String? currentTabGuid}) {
    return Browser(
      tabs: tabs ?? this.tabs,
      currentTabGuid: currentTabGuid ?? this.currentTabGuid,
    )..onUpdate = onUpdate;
  }

  void openNewTab(String? initialUrl) {
    final newTab = Tab();

    if (initialUrl != null) {
      newTab.navigateTo(initialUrl, onUpdate ?? () {});
    }

    tabs.add(newTab);
    currentTabGuid = newTab.guid;
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

      currentTabGuid = tabs.isEmpty ? null : tabs[tabId].guid;
    }
  }

  void switchToTab(String guid) {
    currentTabGuid = guid;
  }
}

Future<Document?> getHttp(Uri uri) async {
  try {
    final page = await http.get(
      uri,
      headers: {
        "User-Agent": "DragonFly/1.0",
      },
    );

    // TODO : check the errors (404, etc)
    return DomBuilder.parse(page.body);
  } catch (e) {
    print(e);
    // TODO : bad error handling but tired of that s***
    return null;
  }
}
