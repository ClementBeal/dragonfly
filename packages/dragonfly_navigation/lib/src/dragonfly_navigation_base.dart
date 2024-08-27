import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:dragonfly_navigation/src/file_explorer/file_explorer.dart';
import 'package:dragonfly_navigation/src/html/dom.dart';
import 'package:html/dom.dart';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

enum PageStatus { loading, error, success }

sealed class Page {
  late final String guid;
  final String url;
  final PageStatus status;

  Page({
    required this.url,
    required this.status,
    String? guid,
  }) {
    this.guid = guid ?? Uuid().v4();
  }

  String? getTitle();
}

class FileExplorerPage extends Page {
  FileExplorerPage(this.result, {required super.url, required super.status});

  final List<ExplorationResult> result;

  @override
  String? getTitle() {
    return "Index of ${url.toString()}";
  }
}

class HtmlPage extends Page {
  final Document? document;
  final CssomTree? cssom;

  HtmlPage(
      {required super.url,
      required super.status,
      super.guid,
      required this.document,
      required this.cssom});

  HtmlPage copyWith({
    Document? document,
    PageStatus? status,
    CssomTree? cssom,
  }) {
    return HtmlPage(
      url: url,
      guid: guid,
      document: document ?? this.document,
      cssom: cssom ?? this.cssom,
      status: status ?? this.status,
    );
  }

  @override
  String? getTitle() {
    return document?.getElementsByTagName("title").firstOrNull?.text;
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

    final scheme = Uri.parse(url).scheme;

    if (scheme == "http" || scheme == "https") {
      _history.add(
        HtmlPage(
          document: null,
          cssom: null,
          status: PageStatus.loading,
          url: url,
        ),
      );
      _currentIndex++;

      final document = await getHttp(Uri.parse(url));
      CssomTree? cssom;

      if (document != null) {
        final linkCssNode =
            document.querySelectorAll('link[rel="stylesheet"]').firstOrNull;
        if (linkCssNode != null) {
          final href = linkCssNode.attributes["href"];
          cssom = await getCss(Uri.parse(url).replace(path: href));
        }
      }

      _history.last = HtmlPage(
        document: document,
        cssom: cssom,
        status: (document != null) ? PageStatus.success : PageStatus.error,
        url: url,
      );
    } else {
      _history.add(
        FileExplorerPage(
          [],
          status: PageStatus.loading,
          url: url,
        ),
      );
      _currentIndex++;

      final result = await exploreDirectory(Uri.parse(url));

      _history.last = FileExplorerPage(
        result,
        status: PageStatus.success,
        url: url,
      );
    }

    onNavigationDone();
  }

  Future<void> refresh(Function() onNavigationDone) async {
    final url = _history.last.url;

    // TO DO -> use correct function
    final scheme = Uri.parse(url).scheme;

    if (scheme == "http" || scheme == "https") {
      _history.last = HtmlPage(
        document: null,
        cssom: null,
        status: PageStatus.loading,
        url: url,
      );

      final document = await getHttp(Uri.parse(url));
      CssomTree? cssom;

      if (document != null) {
        final linkCssNode =
            document.querySelectorAll('link[rel="stylesheet"]').firstOrNull;
        if (linkCssNode != null) {
          final href = linkCssNode.attributes["href"];
          cssom = await getCss(Uri.parse(url).replace(path: href));
        }
      }

      _history.last = HtmlPage(
        document: document,
        cssom: cssom,
        status: (document != null) ? PageStatus.success : PageStatus.error,
        url: url,
      );
    } else if (scheme == "file") {
      _history.last = FileExplorerPage(
        [],
        status: PageStatus.loading,
        url: url,
      );

      _history.last = FileExplorerPage(
        await exploreDirectory(Uri.parse(url)),
        status: PageStatus.success,
        url: url,
      );
    }

    onNavigationDone();
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

      currentTabGuid = tabs.isEmpty ? null : tabs[tabId - 1].guid;
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

Future<CssomTree?> getCss(Uri uri) async {
  try {
    final page = await http.get(
      uri,
      headers: {
        "User-Agent": "DragonFly/1.0",
      },
    );

    return cssomBuilder.parse(page.body);
  } catch (e) {
    print(e);
    // TODO : bad error handling but tired of that s***
    return null;
  }
}

final cssomBuilder = CssomBuilder();
