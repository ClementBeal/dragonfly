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
  Future<void> navigateTo(String url, Function() onNavigationDone) async {
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    final uriRequest = Uri.parse(url);
    final scheme = uriRequest.scheme;

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

      final htmlRequest = await tracker.request(url, "GET", {});

      Document? document;
      CssomTree? cssom;
      BrowserImage? cachedFavicon;

      if (htmlRequest != null) {
        document = DomBuilder.parse(utf8.decode(htmlRequest.body));
        final titleTags = document.getElementsByTagName("title");

        if (titleTags.isNotEmpty) {
          navigationHistory.addLink(uriRequest, titleTags.first.text.trim());
        }

        final linkCssNode =
            document.querySelectorAll('link[rel="stylesheet"]').firstOrNull;

        final linkFavicon = document.querySelector('link[rel="icon"]');

        if (linkFavicon != null) {
          final href = linkFavicon.attributes["href"];
          final faviconUri = href!.startsWith("/")
              ? uriRequest.replace(path: href)
              : Uri.parse(href);

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
          final a = await tracker.request(
              Uri.parse(url).replace(path: href).toString(), "GET", {});

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

      if (!File(url).existsSync()) {
        final result = await exploreDirectory(Uri.parse(url));

        _history.last = FileExplorerPage(
          result,
          status: PageStatus.success,
          url: url,
        );
      } else {
        if (p.extension(Uri.parse(url).toFilePath()) == ".json") {
          _history.last = JsonPage(
            url: Uri.parse(url).toFilePath(),
            status: PageStatus.success,
          );
        } else {
          _history.last = MediaPage(
            true,
            url: Uri.parse(url).toFilePath(),
            status: PageStatus.success,
          );
        }
      }
    }

    onNavigationDone();
  }

  /// Refreshes the current page.
  ///
  /// [onNavigationDone] is a callback function executed when refresh is complete.
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

      final httpRequest = await tracker.request(url, "GET", {});
      final document = (httpRequest != null)
          ? DomBuilder.parse(String.fromCharCodes(httpRequest.body))
          : null;
      CssomTree? cssom;

      if (document != null) {
        final linkCssNode =
            document.querySelectorAll('link[rel="stylesheet"]').firstOrNull;

        if (linkCssNode != null) {
          final href = linkCssNode.attributes["href"];
          final a = await tracker.request(
              Uri.parse(url).replace(path: href).toString(), "GET", {});
          try {
            cssom = cssomBuilder.parse(utf8.decode(a!.body));
          } catch (e) {
            cssom = null;
          }
        }
      }

      _history.last = HtmlPage(
        document: document,
        cssom: cssom,
        status: (httpRequest != null) ? PageStatus.success : PageStatus.error,
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

  /// Returns the currently displayed page, or null if no page is loaded.
  Page? get currentPage => _currentIndex >= 0 ? _history[_currentIndex] : null;

  /// Toggles the pinned state of the tab.
  void togglePin() => isPinned = !isPinned;

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
