import 'package:dragonfly_js/dragonfly_js.dart';
import 'package:test/test.dart';

void main() {
  group('Math operations', () {
    late final JavascriptInterpreter interpreter;

    setUp(() {
      interpreter = JavascriptInterpreter();
    });

    test('Addition integers', () {
      const code = "2 + 3";

      final result = interpreter.execute(code);

      expect(result, equals(5));
    });
  });
}
