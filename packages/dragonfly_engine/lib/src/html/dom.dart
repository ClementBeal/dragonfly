import 'package:html/dom.dart';
import 'package:html/parser.dart';

class DomBuilder {
  static Document parse(String html) {
    return HtmlParser(html).parse();
  }
}
