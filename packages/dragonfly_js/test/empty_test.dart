import 'package:dragonfly_js/dragonfly_js.dart';
import 'package:test/test.dart';

void main() {
  group('Empty', () {
    late final JavascriptInterpreter interpreter;

    setUp(() {
      interpreter = JavascriptInterpreter();
    });

    test('Empty javascript', () {
      const code = "";

      final result = interpreter.execute(code);

      expect(result, isNull);
    });
  });
}
