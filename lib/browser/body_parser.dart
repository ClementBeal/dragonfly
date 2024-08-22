/*
 HML5 specs -> https://www.w3.org/TR/2012/WD-html-markup-20121025/Overview.html#toc
*/

import 'package:flutter/widgets.dart' hide Element;
import 'package:html/dom.dart' hide Text;

class BodyParser {
  final Element? body;

  BodyParser({required this.body});

  List<Widget> parse() {
    if (body == null) {
      return [];
    }

    final widgets = <Widget>[];

    for (var child in body!.children) {
      final localName = child.localName;
      if (localName == "h1") {
        widgets.add(
          Text(
            child.text,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (localName == "h2") {
        widgets.add(
          Text(
            child.text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (localName == "strong") {
        widgets.add(
          Text(
            child.text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
    }

    return widgets;
  }
}
