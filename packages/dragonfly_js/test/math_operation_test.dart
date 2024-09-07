import 'package:dragonfly_js/dragonfly_js.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Math operations',
    () {
      group('Addition', () {
        final additionData = [
          (2, 3, 5),
          (0, 5, 5),
          (2, 3, 5),
          (523, 3, 526),
          (222, 222, 444),
        ];

        for (var data in additionData) {
          test('${data.$1} + ${data.$2}  = ${data.$3}', () {
            final interpreter = JavascriptInterpreter();

            final code = "${data.$1} + ${data.$2}";
            final result = interpreter.execute(code);

            expect(data.$3, equals(result));
          });
        }
      });
    },
  );
}
