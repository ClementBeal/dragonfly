import 'package:dragonfly_js/dragonfly_js.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Math operations',
    () {
      group('Simple numbers', () {
        final additionData = [0, 22, 8239, 182930293, -2, -8, -18293];

        for (var data in additionData) {
          test('$data', () {
            final interpreter = JavascriptInterpreter();

            final code = "$data";
            final result = interpreter.execute(code);

            expect(data, equals(result));
          });
        }
      });

      group('Addition', () {
        final additionData = [
          ('2 + 3', 5),
          ('0 + 5', 5),
          ('2 + 3', 5),
          ('523 + 3', 526),
          ('222 + 222', 444),
          ('-2 + -3', -5),
          ('-5 + -10', -15),
          ('-2 + 3', 1),
          ('5 + -7', -2),
          ('0 + -8', -8),
          ('2.3 + 3', 5.3),
          ('2.3 + 3.5', 5.8),
          ('10.3 + 3.5', 13.8),
          ('10.5 + -3.5', 7.0),
        ];

        for (var data in additionData) {
          test('${data.$1} = ${data.$2}', () {
            final interpreter = JavascriptInterpreter();

            final code = data.$1;
            final result = interpreter.execute(code);

            expect(data.$2, equals(result));
          });
        }
      });

      group('Subtraction', () {
        final subtractionData = [
          ('5 - 2', 3),
          ('2 - 5', -3),
          ('0 - 5', -5),
          ('-2 - 3', -5),
          ('5 - -2', 7),
          ('10 - 3.5', 6.5),
          ('-2.5 - 1.8', -4.3),
        ];

        for (var data in subtractionData) {
          test('${data.$1} = ${data.$2}', () {
            final interpreter = JavascriptInterpreter();

            final code = data.$1;
            final result = interpreter.execute(code);

            expect(data.$2, equals(result));
          });
        }
      });

      group('Multiplication', () {
        final multiplicationData = [
          ('5 * 2', 10),
          ('2 * -5', -10),
          ('0 * 5', 0),
          ('-2 * 3', -6),
          ('5 * -2', -10),
          ('10 * 3.5', 35),
          ('-2.5 * 1.8', -4.5),
        ];

        for (var data in multiplicationData) {
          test('${data.$1} = ${data.$2}', () {
            final interpreter = JavascriptInterpreter();

            final code = data.$1;
            final result = interpreter.execute(code);

            expect(data.$2, equals(result));
          });
        }
      });

      group('Division', () {
        final divisionData = [
          ('10 / 2', 5),
          ('-10 / 2', -5),
          ('10 / -2', -5),
          ('-10 / -2', 5),
          ('5 / 2', 2.5),
          ('0 / 5', 0),
          ('-5 / 2', -2.5),
          ('-2.5 / 0.5', -5),
        ];

        for (var data in divisionData) {
          test('${data.$1} = ${data.$2}', () {
            final interpreter = JavascriptInterpreter();

            final code = data.$1;
            final result = interpreter.execute(code);

            expect(data.$2, equals(result));
          });
        }
      });
    },
  );
}
