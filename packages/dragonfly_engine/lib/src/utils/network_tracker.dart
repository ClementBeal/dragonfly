import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Tracks all network requests and responses.
/// Each request and its updates are broadcast via a stream.
class NetworkTracker {
  final List<NetworkRequest> history = [];
  final _requestStreamController = StreamController<NetworkRequest>.broadcast();

  late final http.Client httpClient;

  NetworkTracker({
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  Stream<NetworkRequest> get requestStream => _requestStreamController.stream;

  /// Sends a request to the specified [url] using the given [method] and [headers].
  /// Any exceptions will be caught, and null will be returned in case of errors.
  Future<NetworkResponse?> request(
    Uri uri,
    String method,
    Map<String, String> headers,
  ) async {
    try {
      final request = http.Request(method, uri)
        ..headers.addAll(headers)
        ..headers["User-Agent"] = "DragonFly/1.0";

      final networkRequest = NetworkRequest(
        url: uri.toString(),
        headers: request.headers,
        method: method,
      );

      history.add(networkRequest);
      _requestStreamController.sink.add(networkRequest);

      final response = await httpClient.send(request);
      final responseBody = await response.stream.toBytes();

      final networkResponse = NetworkResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        body: responseBody,
        contentLengthCompressed: responseBody.length,
        contentLengthUncompressed: responseBody.length,
      );

      networkRequest.response = networkResponse;
      _requestStreamController.sink.add(networkRequest);

      return networkResponse;
    } catch (e) {
      return null;
    }
  }

  /// Clear the history
  ///
  /// Must be called each time than the browser makes a new request
  void clear() => history.clear();
}

/// Store the all the information of a network request.
/// May contains a [response].
class NetworkRequest {
  NetworkResponse? response;
  final String url;
  final Map<String, String> headers;
  final String method;

  late final DateTime timestamp;
  late final int headersLength;

  NetworkRequest({
    required this.url,
    required this.headers,
    required this.method,
  }) {
    timestamp = DateTime.now();

    // the `fold` is summing the length of the key and the value
    // because the structure is like this "...": "..."
    //                                    |   ||||   |
    // we have to add 6 characters for each entry
    headersLength = headers.entries.fold(
      0,
      (sum, header) => sum + header.key.length + header.value.length + 6,
    );
  }
}

/// Store the data and headers of a http response
class NetworkResponse {
  final int statusCode;
  final Map<String, String> headers;

  final Uint8List body;
  late final DateTime timestamp;
  late final int headersLength;
  final int contentLengthUncompressed;
  final int contentLengthCompressed;

  NetworkResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.contentLengthUncompressed,
    required this.contentLengthCompressed,
  }) {
    timestamp = DateTime.now();

    // the `fold` is summing the length of the key and the value
    // because the structure is like this "...": "..."
    //                                    |   ||||   |
    // we have to add 6 characters for each entry
    headersLength = headers.entries.fold(
      0,
      (sum, header) => sum + header.key.length + header.value.length + 6,
    );
  }
}
