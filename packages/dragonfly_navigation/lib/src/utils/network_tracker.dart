import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// The [NetworkTracker] keeps an history of all the requests.
///
/// Each new request and its update are sent via a stream.
class NetworkTracker {
  late final List<NetworkRequest> history;
  late final http.Client httpClient;
  late Stream<NetworkRequest> requestStream;
  late StreamController<NetworkRequest> _requestStreamController;

  NetworkTracker({
    http.Client? httpClient,
  }) {
    history = [];
    _requestStreamController = StreamController.broadcast();
    requestStream = _requestStreamController.stream;
    this.httpClient = httpClient ?? http.Client();
  }

  /// Launch a request to the specified [url] and with the specified [headers]
  ///
  /// All the exceptions will be caught.
  Future<NetworkResponse?> request(
    String url,
    String method,
    Map<String, String> headers,
  ) async {
    try {
      final request = http.Request(
        method,
        Uri.parse(url),
      );

      for (var v in headers.entries) {
        request.headers[v.key] = v.value;
      }

      final networkRequest = NetworkRequest(
        url: url,
        headers: headers,
      );

      history.add(networkRequest);

      _requestStreamController.sink.add(networkRequest);

      final response = await httpClient.send(
        request,
      );

      final responseBody = await response.stream.toBytes();

      final responseToReturn = NetworkResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        body: responseBody,
        contentLengthCompressed: responseBody.length,
        contentLengthUncompressed: responseBody.length,
      );

      history
          .firstWhere(
            (e) => e == networkRequest,
          )
          .response = responseToReturn;

      _requestStreamController.sink.add(networkRequest);

      return responseToReturn;
    } catch (e) {
      return null;
    }
  }

  /// Clear the history
  ///
  /// Must be called each time than the browser makes a new request
  void clear() {
    history.clear();
  }
}

/// Store the all the information of a network request.
/// May contains a [response].
class NetworkRequest {
  late NetworkResponse? response;
  final String url;
  final Map<String, String> headers;
  late final DateTime timestamp;

  NetworkRequest({required this.url, required this.headers}) {
    timestamp = DateTime.now();
    response = null;
  }
}

/// Store the data and headers of a http response
class NetworkResponse {
  final int statusCode;
  final Map<String, String> headers;
  final Uint8List body;
  late final DateTime timestamp;
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
  }
}
