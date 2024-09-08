import 'package:dragonfly_js/src/parser/js_parser.dart';

class JavascriptInterpreter {
  late final JavascriptParser parser;

  JavascriptInterpreter() {
    parser = JavascriptParser();
  }

  dynamic execute(String code) {
    if (code.isEmpty) return null;

    return parser.parse(code).evaluate();
  }
}
