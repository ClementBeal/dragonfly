import 'package:dragonfly_engine/src/utils/network_tracker.dart';
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
              method: "GET",
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
                  [],
                ),
                200,
              ),
            ],
          ),
        );

        final response = await tracker.request(Uri(), "GET", {});

        expect(tracker.history.length, 1);

        expect(response, isNotNull);
        expect(response!.statusCode, 200);
        expect(response.headers, isEmpty);
        expect(response.body, isEmpty);
      });

      test("Very basic GET request ; no headers ; body", () async {
        final tracker = NetworkTracker(
          httpClient: HTTPClientMock(
            [
              http.StreamedResponse(
                Stream.fromIterable(
                  [
                    [0, 1, 2],
                  ],
                ),
                200,
              ),
            ],
          ),
        );

        final response = await tracker.request(Uri(), "GET", {});

        expect(tracker.history.length, 1);

        expect(response, isNotNull);
        expect(response!.statusCode, 200);
        expect(response.headers, isEmpty);
        expect(response.body, [0, 1, 2]);
      });

      test("The history must contain the response", () async {
        final tracker = NetworkTracker(
          httpClient: HTTPClientMock(
            [
              http.StreamedResponse(
                Stream.fromIterable(
                  [
                    [0, 1, 2],
                  ],
                ),
                200,
              ),
            ],
          ),
        );

        final response = await tracker.request(Uri(), "GET", {});

        expect(tracker.history.length, 1);
        expect(tracker.history.first.response, response);

        expect(response, isNotNull);
        expect(response!.statusCode, 200);
        expect(response.headers, isEmpty);
        expect(response.body, [0, 1, 2]);
      });

      test("The history must contain the response", () async {
        final tracker = NetworkTracker(
          httpClient: HTTPClientMock(
            [
              http.StreamedResponse(
                Stream.fromIterable(
                  [
                    [0, 1, 2],
                  ],
                ),
                200,
              ),
            ],
          ),
        );

        final List<NetworkRequest> streamMessages = [];

        final subscription = tracker.requestStream.listen((message) {
          streamMessages.add(message);
        });

        final response = await tracker.request(Uri(), "GET", {});

        await Future.delayed(Duration(milliseconds: 100));
        subscription.cancel();

        expect(streamMessages.length, 2);

        final lastMessage = streamMessages.last;

        expect(lastMessage.response, response);
      });
    },
  );
}
