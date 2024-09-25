import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
      await _navigateHttpScheme(uri);
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

  Future<void> _navigateHttpScheme(Uri uri) async {
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

    if (htmlRequest != null &&
        htmlRequest.statusCode >= 200 &&
        htmlRequest.statusCode < 300) {
      // the request is not empty and has a correct status code
      // we can create the dom
      // add the current uri to the history
      // load the favicon and the CSS if they exist
      final document = DomBuilder.parse(utf8.decode(htmlRequest.body));

      _updateNavigationHistory(uri, document);

      final faviconFuture = _fetchFavicon(document, uri);

      final linkCssNode = document.querySelectorAll('link[rel="stylesheet"]');

      final result = await Future.wait(
        [
          faviconFuture,
          ...linkCssNode.map(
            (e) => _downloadCSSFile(uri, e.attributes["href"]!),
          )
        ],
      );

      // we should merge the the CSSom trees
      final cssomPage =
          (result.length > 1) ? result.skip(1).first as CssomTree? : null;

      _history.last = HtmlPage(
        document: document,
        cssom: cssomPage ?? CssomBuilder().parse(css),
        favicon: result.first as BrowserImage?,
        status: PageStatus.success,
        uri: uri,
      );
    } else {
      _history.last = HtmlPage(
        document: null,
        cssom: null,
        favicon: null,
        status: PageStatus.error,
        uri: uri,
      );
    }
  }

  Future<CssomTree?> _downloadCSSFile(Uri uri, String href) async {
    final response = await tracker.request(uri.replace(path: href), "GET", {});

    try {
      if (response != null &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        return CssomBuilder().parse(
          utf8.decode(response.body),
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Updates the navigation history with the current URI and document title.
  void _updateNavigationHistory(Uri uri, Document document) {
    final titleTags = document.getElementsByTagName("title");
    if (titleTags.isNotEmpty) {
      navigationHistory.addLink(uri, titleTags.first.text.trim());
    }
  }

  /// Fetches the favicon, if present in the document.
  Future<BrowserImage?> _fetchFavicon(Document document, Uri uri) async {
    final linkFavicon = document.querySelector('link[rel="icon"]');
    if (linkFavicon == null) return null;

    final href = linkFavicon.attributes["href"];
    if (href == null) return null;

    final faviconUri =
        href.startsWith("/") ? uri.replace(path: href) : Uri.parse(href);

    BrowserImage? cachedFavicon = FileCache.getCacheFile(faviconUri);

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

    return cachedFavicon;
  }

  Future<Uint8List?> downloadImage(
    String imageUrl,
  ) async {
    final baseUri = _history.last.uri;
    // Resolve the image URL to a full URI.
    Uri goodUrl;

    if (imageUrl.startsWith("/")) {
      // Relative URL with leading slash, resolve against the base URI.
      goodUrl = baseUri.replace(path: imageUrl);
    } else if (imageUrl.startsWith("http") || imageUrl.startsWith("https")) {
      // Absolute URL, use as-is.
      goodUrl = Uri.parse(imageUrl);
    } else {
      // Relative URL without leading slash, resolve against the base URI.
      final currentPath =
          baseUri.path.endsWith("/") ? baseUri.path : "${baseUri.path}/";
      goodUrl = baseUri.replace(path: currentPath + imageUrl);
    }

    final imageResponse = await tracker.request(goodUrl, "GET", {});

    print(imageResponse?.statusCode);
    print(imageResponse?.headers);

    return imageResponse?.body;
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
