import 'package:dragonfly_navigation/src/utils/network_tracker.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:http/http.dart' as http;

class HTTPClientMock extends http.BaseClient {
  final List<http.StreamedResponse> _responses;
  int _currentIndex = 0;

  HTTPClientMock(this._responses);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final response = _responses[_currentIndex];
    _currentIndex++;

    return Future.value(response);
  }
}

void main() {
  group(
    "Network tracker",
    () {
      test(
        "Clear the history",
        () {
          final tracker = NetworkTracker(httpClient: HTTPClientMock([]));

          tracker.history.add(
            NetworkRequest(
              url: "random url",
              headers: {},
            ),
          );

          expect(tracker.history.length, 1);
          tracker.clear();
          expect(tracker.history, isEmpty);
        },
      );

      test("Very basic GET request ; no headers ; empty body", () async {
        final tracker = NetworkTracker(
          httpClient: HTTPClientMock(
            [
              http.StreamedResponse(
                Stream.fromIterable(
                  [
                    [0],
                  ],
                ),
                200,
              ),
            ],
          ),
        );

        final response = await tracker.request("url", "GET", {});

        expect(tracker.history.length, 1);

        expect(response, isNotNull);
        expect(response!.statusCode, 200);
        expect(response.headers, isEmpty);
        expect(response.body, isEmpty);
      });
    },
  );
}
