import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dragonfly/browser/css/cssom_builder.dart';
import 'package:dragonfly/browser/dom/html_node.dart';
import 'package:dragonfly/browser/dom_builder.dart';
import 'package:http/http.dart' as http;

enum NavigationError {
  cantFindPage("Server not Found");

  const NavigationError(this.title);
  final String title;
}

enum FaviconType {
  unknown,
  url,
  png,
  jpeg,
  gif,
  svg,
  ico, // Common favicon format
  // ... add other types as needed ...
}

class Favicon {
  final String href;

  Favicon({required this.href});

  FaviconType get type {
    if (href.startsWith('data:')) {
      final mimeType =
          href.split(';')[0].substring(5); // Extract "image/png" etc.

      switch (mimeType) {
        case 'image/png':
          return FaviconType.png;
        case 'image/jpeg':
          return FaviconType.jpeg;
        case 'image/gif':
          return FaviconType.gif;
        case 'image/svg+xml':
          return FaviconType.svg;
        // ... add more cases as needed ...
        default:
          return FaviconType.unknown;
      }
    } else if (href.startsWith('http://') || href.startsWith('https://')) {
      return FaviconType.url;
    } else {
      // Try to infer from file extension (less reliable)
      final extension = href.split('.').last.toLowerCase();
      switch (extension) {
        case 'png':
          return FaviconType.png;
        case 'jpg':
        case 'jpeg':
          return FaviconType.jpeg;
        case 'gif':
          return FaviconType.gif;
        case 'svg':
          return FaviconType.svg;
        case 'ico':
          return FaviconType.ico;
        // ... add more cases as needed ...
        default:
          return FaviconType.unknown;
      }
    }
  }

  Uint8List? decodeBase64() {
    if (type != FaviconType.url && href.contains(';base64,')) {
      final base64Data = href.split(';base64,').last;
      return base64Decode(base64Data);
    }
    return null; // Not a Base64-encoded favicon
  }

  // ... additional methods you might want:
  // - ImageProvider? get imageProvider  (returns a provider for Flutter Image widget)
  // - String? get fileExtension
  // ...
}

class Tab {
  final List<Response> history;
  int currentPageId;
  String sourceCode;

  Tab({
    required this.history,
    this.currentPageId = 0,
    this.sourceCode = "",
  });

  bool isLoading() => history.last is Loading;
  Response? get currentResponse => getCurrentPage();
  Favicon? get favicon => history.whereType<Success>().firstOrNull?.favicon;

  void addPage(Response response) {
    history.add(response);
    currentPageId++;
  }

  void refresh() {
    history.last = Loading(uri: history.last.uri);
  }

  void setLastPage(Response response) {
    history.last = response;
  }

  Response? getCurrentPage() {
    if (history.isEmpty || history.length < currentPageId) return null;
    return history[currentPageId];
  }

  void nextPage() {
    currentPageId++;
  }

  bool get canNavigateNext => history.length > currentPageId + 1;
  bool get canNavigatePrevious => currentPageId - 1 >= 0;

  void previousPage() {
    currentPageId--;
  }
}

sealed class Response {
  final Uri uri;
  final String? title;

  Response({
    required this.uri,
    required this.title,
  });
}

class Success extends Response {
  Success({
    required super.uri,
    required super.title,
    required this.content,
    required this.favicon,
    required this.sourceCode,
  });

  final Tree content;
  CSSOM? theme;
  final Favicon? favicon;
  final String sourceCode;
}

class Loading extends Response {
  Loading({
    required super.uri,
  }) : super(title: 'Loading...');
}

class Empty extends Response {
  Empty({
    required super.uri,
  }) : super(title: '');
}

class ErrorResponse extends Response {
  final NavigationError error;

  ErrorResponse({
    required super.uri,
    required this.error,
    required super.title,
  });
}

Future<Response> getHttp(Uri uri) async {
  try {
    final page = await http.get(
      uri,
      headers: {
        "User-Agent": "DragonFly/1.0",
      },
    );

    final dom = DomBuilder().parse(page.body);
    final title =
        dom.findSubtreesOfType<TitleNode>(dom).firstOrNull?.data as TitleNode;

    return Success(
      uri: uri,
      title: (title).title,
      favicon: null,
      content: dom,
      sourceCode: page.body,
    )..theme = CSSOM.initial();
  } catch (e) {
    print(e);
    return ErrorResponse(
      uri: uri,
      error: NavigationError.cantFindPage,
      title: NavigationError.cantFindPage.title,
    );
  }
}

Future<CSSOM> getCSS(Uri uri) async {
  final page = await http.get(
    uri,
    headers: {
      "User-Agent": "DragonFly/1.0",
    },
  );

  final theme = CssomBuilder().parse(page.body);

  // theme.addTheme(
  //   ANode,
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     listDecoration: ListDecoration.none,
  //     textColor: Color(0xff333333),
  //     textDecoration: null,
  //   ),
  // );
  // theme.addTheme(
  //   H1Node,
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     fontWeight: FontWeight.w400,
  //     lineHeight: 1.2,
  //     margin: EdgeInsets.only(
  //       bottom: theme.fontSize.getValue(FontSizeType.rem, 1).value,
  //     ),
  //   ),
  // );
  // theme.addTheme(
  //   H2Node,
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     fontWeight: FontWeight.w400,
  //     lineHeight: 1.2,
  //     margin: EdgeInsets.only(
  //       bottom: theme.fontSize.getValue(FontSizeType.rem, 1).value,
  //     ),
  //   ),
  // );
  // theme.addTheme(
  //   H3Node,
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     fontWeight: FontWeight.w400,
  //     lineHeight: 1.2,
  //     margin: EdgeInsets.only(
  //       bottom: theme.fontSize.getValue(FontSizeType.rem, 1).value,
  //     ),
  //   ),
  // );

  // theme.addTheme(
  //   BodyNode,
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     lineHeight: 1.6,
  //     textColor: Color(0xff333),
  //     backgroundColor: Color(0xfff4f4f4),
  //   ),
  // );

  // theme.addClass(
  //   "main-nav",
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     displayType: DisplayType.flex,
  //     justifyContent: MainAxisAlignment.spaceBetween,
  //     alignItems: CrossAxisAlignment.center,
  //   ),
  // );

  // theme.addClass(
  //   "header",
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     backgroundColor: Color(0xFFFFFFFF),
  //     margin: EdgeInsets.symmetric(
  //       horizontal: theme.fontSize.getValue(FontSizeType.rem, 1).value,
  //     ),
  //   ),
  // );
  // theme.addClass(
  //   "footer",
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     textColor: Color(0xffffffff),
  //     backgroundColor: Color(0xFF333333),
  //     textAlign: TextAlign.center,
  //     margin: EdgeInsets.symmetric(
  //       horizontal: theme.fontSize.getValue(FontSizeType.rem, 1).value,
  //     ),
  //   ),
  // );
  // theme.addClass(
  //   "container",
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     isCentered: true,
  //     maxWidth: 1200,
  //     margin: EdgeInsets.symmetric(
  //       vertical: theme.fontSize.getValue(FontSizeType.rem, 1).value,
  //     ),
  //   ),
  // );
  // theme.addClass(
  //   "testimonials",
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     textAlign: TextAlign.center,
  //     backgroundColor: Color(0xfff8f8f8),
  //     margin: EdgeInsets.symmetric(
  //       horizontal: theme.fontSize.getValue(FontSizeType.rem, 4).value,
  //     ),
  //   ),
  // );
  // theme.addClass(
  //   "testimonial",
  //   CssTheme(
  //     customTagTheme: {},
  //     classes: {},
  //     border: Border(left: BorderSide(color: Color(0xff007bff), width: 5)),
  //     textAlign: TextAlign.center,
  //     backgroundColor: Color(0xfff8f8f8),
  //     margin: EdgeInsets.only(
  //       bottom: theme.fontSize.getValue(FontSizeType.rem, 2).value,
  //     ).add(EdgeInsets.all(2)).resolve(TextDirection.ltr),
  //   ),
  // );

  return theme;
}
