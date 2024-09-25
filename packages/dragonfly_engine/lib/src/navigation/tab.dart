import 'dart:convert';
import 'dart:io';

import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:dragonfly_engine/src/css/css_browser_theme.dart';
import 'package:dragonfly_engine/src/css/cssom_builder.dart';
import 'package:dragonfly_engine/src/file_explorer/file_explorer.dart';
import 'package:dragonfly_engine/src/files/cache_file.dart';
import 'package:dragonfly_engine/src/files/favicon.dart';
import 'package:dragonfly_engine/src/html/dom.dart';
import 'package:dragonfly_engine/src/pages/a_page.dart';
import 'package:dragonfly_engine/src/utils/network_tracker.dart';
import 'package:dragonfly_js/dragonfly_js.dart';
import 'package:html/dom.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

enum PageStatus { loading, error, success }

/// Represents a browser tab.
class Tab {
  /// Unique identifier for the tab.
  late final String guid;

  /// Javascript interpreter associated with the tab.
  late final JavascriptInterpreter interpreter;

  /// Browsing history of the tab.
  final List<Page> _history = [];

  /// Network tracker for monitoring network requests.
  final NetworkTracker tracker = NetworkTracker();

  /// Global navigation history across all tabs.
  final NavigationHistory navigationHistory;

  /// Index of the current page in the history.
  int _currentIndex = -1;

  /// Whether the tab is pinned.
  bool isPinned = false;

  /// Order of the tab in the tab bar.
  int order;

  /// Creates a new Tab instance.
  ///
  /// [order] specifies the order of the tab.
  /// [navigationHistory] provides access to the global navigation history.
  Tab({
    required this.order,
    required this.navigationHistory,
  })  : guid = Uuid().v4(),
        interpreter = JavascriptInterpreter();

  /// Navigates the tab to the specified URL.
  ///
  /// [url] is the URL to navigate to.
  /// [onNavigationDone] is a callback function executed when navigation is complete.
  Future<void> navigateTo(Uri uri, Function() onNavigationDone) async {
    // remove the history after the current index
    // it happends when the user has navigated backward
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    final scheme = uri.scheme;

    if (scheme == "http" || scheme == "https") {
      _history.add(
        HtmlPage(
          document: null,
          cssom: null,
          status: PageStatus.loading,
          uri: uri,
        ),
      );
      _currentIndex++;

      final htmlRequest = await tracker.request(uri, "GET", {});

      Document? document;
      CssomTree? cssom;
      BrowserImage? cachedFavicon;

      if (htmlRequest != null) {
        document = DomBuilder.parse(utf8.decode(htmlRequest.body));
        final titleTags = document.getElementsByTagName("title");

        if (titleTags.isNotEmpty) {
          navigationHistory.addLink(uri, titleTags.first.text.trim());
        }

        final linkCssNode =
            document.querySelectorAll('link[rel="stylesheet"]').firstOrNull;

        final linkFavicon = document.querySelector('link[rel="icon"]');

        if (linkFavicon != null) {
          final href = linkFavicon.attributes["href"];
          final faviconUri =
              href!.startsWith("/") ? uri.replace(path: href) : Uri.parse(href);

          cachedFavicon = FileCache.getCacheFile(faviconUri);

          if (cachedFavicon == null) {
            final faviconData = await http.get(faviconUri);
            final cachedFaviconUri =
                FileCache.cacheFile(faviconUri, faviconData.bodyBytes);

            cachedFavicon = BrowserImage(
              path: cachedFaviconUri,
              mimetype: lookupMimeType(
                cachedFaviconUri.toFilePath(),
              )!,
            );

            FileCacheRepo(db).addFileToCache(
              p.basename(cachedFaviconUri.toString()),
              faviconUri.toString(),
              faviconData.headers["content-type"]!,
            );
          }
        }

        if (linkCssNode != null) {
          final href = linkCssNode.attributes["href"];
          final a = await tracker.request(uri.replace(path: href), "GET", {});

          try {
            cssom = cssomBuilder.parse(utf8.decode(a!.body));
          } catch (e) {
            cssom = null;
          }
        }
      }

      _history.last = HtmlPage(
        document: document,
        cssom: cssom ?? CssomBuilder().parse(css),
        favicon: cachedFavicon,
        status: (document != null) ? PageStatus.success : PageStatus.error,
        uri: uri,
      );
    } else if (scheme == "file") {
      await _navigateFileScheme(uri);
    }

    onNavigationDone();
  }

  /// Refreshes the current page.
  ///
  /// [onNavigationDone] is a callback function executed when refresh is complete.
  Future<void> refresh(Function() onNavigationDone) async {
    _currentIndex--;
    navigateTo(_history.last.uri, onNavigationDone);
  }

  /// Navigate to a page with the scheme "file://"
  /// The navigation doesn't need internet connection
  Future<void> _navigateFileScheme(Uri uri) async {
    _history.add(
      FileExplorerPage(
        [],
        status: PageStatus.loading,
        uri: uri,
      ),
    );

    _currentIndex++;

    if (!File.fromUri(uri).existsSync()) {
      final result = await exploreDirectory(uri);

      _history.last = FileExplorerPage(
        result,
        status: PageStatus.success,
        uri: uri,
      );
    } else {
      final filePath = uri.toFilePath();
      final fileExtension = p.extension(filePath).toLowerCase();

      if (fileExtension == ".json") {
        _history.last = JsonPage(
          uri: uri,
          status: PageStatus.success,
        );
      } else {
        _history.last = MediaPage(
          true,
          uri: uri,
          status: PageStatus.success,
        );
      }
    }
  }

  /// Returns the currently displayed page, or null if no page is loaded.
  Page? get currentPage => _currentIndex >= 0 ? _history[_currentIndex] : null;

  /// Toggles the pinned state of the tab.
  void togglePin() => isPinned = !isPinned;

  /// Checks if the tab can be refreshed
  bool canRefresh() => _currentIndex >= 0;

  /// Checks if the tab can navigate back in history.
  bool canGoBack() => _currentIndex > 0;

  /// Checks if the tab can navigate forward in history.
  bool canGoForward() => _currentIndex < _history.length - 1;

  /// Navigates back in the tab's history.
  void goBack() {
    if (canGoBack()) {
      _currentIndex--;
    }
  }

  /// Navigates forward in the tab's history.
  void goForward() {
    if (canGoForward()) {
      _currentIndex++;
    }
  }
}

final cssomBuilder = CssomBuilder();