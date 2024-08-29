import 'package:dragonfly/utils/url_detection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    "URL Detection",
    () {
      final data = {
        "google.com": "http://google.com",
        "facebook.net": "http://facebook.net",
        "/home/user": "file:///home/user",
        "random": "https://www.google.com/search?q=random",
        "google": "https://www.google.com/search?q=google"
      };

      for (var entry in data.entries) {
        final input = entry.key;
        final expectedResult = entry.value;

        test('', () {
          expect(detectUrl(input), expectedResult);
        });
      }
    },
  );
}
