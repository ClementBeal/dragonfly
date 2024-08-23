import 'package:collection/collection.dart';
import 'package:dragonfly/browser/body_parser.dart';
import 'package:flutter/widgets.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

enum NavigationError {
  cantFindPage("Server not Found");

  const NavigationError(this.title);
  final String title;
}

class Tab {
  final List<Response> history;
  int currentPageId;

  Tab({required this.history, this.currentPageId = 0});

  bool isLoading() => history.last is Loading;
  Response? get currentResponse => getCurrentPage();
  String? get favicon => history.whereType<Success>().firstOrNull?.favicon;

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
    print(history);
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
  });

  final Widget content;
  final String? favicon;
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

    final xml = parse(page.body);

    final body = xml.querySelector("body");
    print(body);

    return Success(
      uri: uri,
      title: xml.querySelector("head > title")?.text,
      favicon: xml.querySelector('link[rel="icon"]')?.attributes['href'],
      content: BodyParser().parse(body),
    );
  } catch (e) {
    print(e);
    return ErrorResponse(
      uri: uri,
      error: NavigationError.cantFindPage,
      title: NavigationError.cantFindPage.title,
    );
  }
}
