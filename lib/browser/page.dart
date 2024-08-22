import 'package:dragonfly/browser/body_parser.dart';
import 'package:flutter/widgets.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

enum NavigationError {
  cantFindPage("Server not Found");

  const NavigationError(this.title);
  final String title;
}

sealed class Response {
  final Uri uri;
  final String? title;

  Response({required this.uri, required this.title});
}

class Success extends Response {
  Success({
    required super.uri,
    required super.title,
    required this.content,
  });

  final List<Widget> content;
}

class Loading extends Response {
  Loading({
    required super.uri,
  }) : super(title: 'Loading...');
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

    return Success(
      uri: uri,
      title: xml.querySelector("head > title")?.text,
      content: BodyParser(body: body).parse(),
    );
  } catch (e) {
    return ErrorResponse(
      uri: uri,
      error: NavigationError.cantFindPage,
      title: NavigationError.cantFindPage.title,
    );
  }
}
