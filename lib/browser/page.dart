import 'package:http/http.dart' as http;

enum NavigationError {
  cantFindPage,
}

sealed class Response {
  final Uri uri;

  Response({required this.uri});
}

class Success extends Response {
  Success({required super.uri});
}

class Loading extends Response {
  Loading({required super.uri});
}

class ErrorResponse extends Response {
  final NavigationError error;

  ErrorResponse({required super.uri, required this.error});
}

Future<Response> getHttp(Uri uri) async {
  try {
    final page = await http.get(
      uri,
      headers: {
        "User-Agent": "DragonFly/1.0",
      },
    );
  } catch (e) {
    return ErrorResponse(uri: uri, error: NavigationError.cantFindPage);
  }

  return Success(uri: uri);
}
