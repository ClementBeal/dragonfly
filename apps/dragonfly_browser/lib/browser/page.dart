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
  webp,
  ico, // Common favicon format
  // ... add other types as needed ...
}

class Favicon {
  final String href;
  bool isMemoryImage = false;

  Favicon({required this.href});

  FaviconType get type {
    if (href.startsWith('data:')) {
      final mimeType =
          href.split(';')[0].substring(5); // Extract "image/png" etc.
      isMemoryImage = true;

      switch (mimeType) {
        case 'image/png':
          return FaviconType.png;
        case 'image/jpeg':
          return FaviconType.jpeg;
        case 'image/webp':
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
        case 'webp':
          return FaviconType.webp;
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
}

// Future<Response> getHttp(Uri uri) async {
//   try {
//     final page = await http.get(
//       uri,
//       headers: {
//         "User-Agent": "DragonFly/1.0",
//       },
//     );

//     final dom = DomBuilder().parse(page.body);
//     final title =
//         dom.findSubtreesOfType<TitleNode>(dom).firstOrNull?.data as TitleNode;

//     return Success(
//       uri: uri,
//       title: (title).title,
//       favicon: null,
//       content: dom,
//       sourceCode: page.body,
//     )..theme = CSSOM.initial();
//   } catch (e) {
//     print(e);
//     return ErrorResponse(
//       uri: uri,
//       error: NavigationError.cantFindPage,
//       title: NavigationError.cantFindPage.title,
//     );
//   }
// }

// Future<CSSOM> getCSS(Uri uri) async {
//   final page = await http.get(
//     uri,
//     headers: {
//       "User-Agent": "DragonFly/1.0",
//     },
//   );

//   final theme = CssomBuilder().parse(page.body);

//   return theme;
// }
