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

class CSSStylesheet {
  final String name;
  final String content;
  final bool isVisible;
  final bool isBrowserStyle;

  CSSStylesheet({
    required this.name,
    required this.content,
    required this.isVisible,
    this.isBrowserStyle = false,
  });
}

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

  /// To trigger a function when the tab is updated
  Function()? onUpdate;

  /// Creates a new Tab instance.
  ///
  /// [order] specifies the order of the tab.
  /// [navigationHistory] provides access to the global navigation history.
  Tab({
    required this.order,
    required this.navigationHistory,
    this.onUpdate,
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

  Future<void> _navigateHttpScheme(
    Uri uri, {
    String method = "GET",
    Map<String, FormData> data = const {},
    Map<String, String> headers = const {},
  }) async {
    if (method == "GET" && data.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        for (final a in data.entries) a.key: a.value.getValue()
      });
    }

    _history.add(
      HtmlPage(
        document: null,
        stylesheets: [],
        status: PageStatus.loading,
        uri: uri,
      ),
    );
    _currentIndex++;

    final htmlRequest = await tracker.request(
      uri,
      method,
      headers,
      data: data,
    );

    if (htmlRequest != null &&
        htmlRequest.statusCode >= 200 &&
        htmlRequest.statusCode < 300) {
      // the request is not empty and has a correct status code
      // we can create the dom
      // add the current uri to the history
      // load the favicon and the CSS if they exist
      final document =
          DomBuilder.parse(utf8.decode(htmlRequest.body, allowMalformed: true));

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

      final allStylesheets = result
          .skip(1)
          .cast<CSSStylesheet?>()
          .whereType<CSSStylesheet>()
          .toList();

      _history.last = HtmlPage(
        document: document,
        stylesheets: [
          CSSStylesheet(
            name: "",
            isVisible: true,
            content: css,
            isBrowserStyle: true,
          ),
          ...allStylesheets
        ],
        favicon: result.first as BrowserImage?,
        status: PageStatus.success,
        uri: uri,
      );
    } else {
      print("error here");

      _history.last = HtmlPage(
        document: null,
        stylesheets: [],
        favicon: null,
        status: PageStatus.error,
        uri: uri,
      );
    }
  }

  /// Return the CSS string
  Future<CSSStylesheet?> _downloadCSSFile(Uri baseUri, String href) async {
    Uri goodUrl;

    if (href.startsWith("/")) {
      // Relative URL with leading slash, resolve against the base URI.
      goodUrl = baseUri.replace(path: href);
    } else if (href.startsWith("http") || href.startsWith("https")) {
      // Absolute URL, use as-is.
      goodUrl = Uri.parse(href);
    } else {
      // Relative URL without leading slash, resolve against the base URI.
      final currentPath =
          baseUri.path.endsWith("/") ? baseUri.path : "${baseUri.path}/";
      goodUrl = baseUri.replace(path: currentPath + href);
    }

    final response = await tracker.request(goodUrl, "GET", {});

    try {
      if (response != null &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        return CSSStylesheet(
          content: utf8.decode(response.body),
          isVisible: true,
          name: baseUri.path,
        );
      } else {
        print(response?.statusCode);
        return null;
      }
    } catch (e) {
      print(e);
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

    Uri faviconUri;

    if (href.startsWith("/")) {
      // Relative URL with leading slash, resolve against the base URI.
      faviconUri = uri.replace(path: href);
    } else if (href.startsWith("http") || href.startsWith("https")) {
      // Absolute URL, use as-is.
      faviconUri = Uri.parse(href);
    } else {
      // Relative URL without leading slash, resolve against the base URI.
      final currentPath = uri.path.endsWith("/") ? uri.path : "${uri.path}/";
      faviconUri = uri.replace(path: currentPath + href);
    }

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
    if (imageUrl.startsWith("data:")) {
      final base64Data = imageUrl.split(',').last;

      try {
        return base64Decode(base64Data);
      } catch (e) {
        print("Error decoding base64 image: $e");
        return null;
      }
    }

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

  Future<void> sendForm(
      String action, String formMethod, Map<String, FormData> data) async {
    Uri actionUri;
    final currentPageUri = currentPage?.uri;

    if (currentPage == null) {
      return;
    }

    print(action);

    if (action.startsWith("/")) {
      // Relative URL with leading slash, resolve against the base URI.
      actionUri = currentPageUri!.replace(path: action);
    } else if (action.startsWith("http") || action.startsWith("https")) {
      // Absolute URL, use as-is.
      actionUri = Uri.parse(action);
    } else {
      // Relative URL without leading slash, resolve against the base URI.
      final currentPath = currentPageUri!.path.endsWith("/")
          ? currentPageUri.path
          : "${currentPageUri.path}";

      actionUri = currentPageUri.replace(path: currentPath + action);
    }

    final headers = <String, String>{};

    await _navigateHttpScheme(
      actionUri,
      method: formMethod,
      data: data,
      headers: headers,
    );

    onUpdate?.call();
  }

  void removeElementFromDOM(Element elementToRemove) {
    final page = currentPage;

    if (page == null || page is! HtmlPage) return;

    final document = page.document;

    if (document == null) return;

    for (var child in document.children) {
      if (child == elementToRemove) {
        elementToRemove.remove();
        break;
      }

      if (_removeElementFromDOM(child, elementToRemove)) break;
    }

    onUpdate?.call();
  }

  bool _removeElementFromDOM(Element parent, Element elementToRemove) {
    for (var child in parent.children) {
      if (child == elementToRemove) {
        elementToRemove.remove();
        return true;
      }

      if (_removeElementFromDOM(child, elementToRemove)) return true;
    }

    return false;
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

sealed class FormData {
  dynamic getValue();
}

class FormDataText extends FormData {
  final String value;

  FormDataText(this.value);

  @override
  dynamic getValue() {
    return value;
  }
}

class FormDataFile extends FormData {
  final String filePath;

  FormDataFile({required this.filePath});

  @override
  dynamic getValue() {
    return File(filePath).readAsBytesSync();
  }
}
