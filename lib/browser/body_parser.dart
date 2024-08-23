/*
 HML5 specs -> https://www.w3.org/TR/2012/WD-html-markup-20121025/Overview.html#toc
*/

import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/dom.dart' hide Text;

class BodyParser {
  Map<String, Widget Function(Element element)> structureTag() {
    return {
      "body": (e) => Column(
            mainAxisSize: MainAxisSize.min,
            children: e.children.map((child) => parse(child)).toList(),
          ),
    };
  }

  Map<String, Widget Function(Element element)> headerTag() {
    return {
      "h1": (element) => Text(
            element.text,
            style: TextStyle(
              fontSize: 32, // 2.0
              fontWeight: FontWeight.bold,
            ),
          ),
      "h2": (element) => Text(
            element.text,
            style: TextStyle(
              fontSize: 24, // 1.5
              fontWeight: FontWeight.bold,
            ),
          ),
      "h3": (element) => Text(
            element.text,
            style: TextStyle(
              fontSize: 18.72, // 1.17
              fontWeight: FontWeight.bold,
            ),
          ),
      "h4": (element) => Text(
            element.text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
      "h5": (element) => Text(
            element.text,
            style: TextStyle(
              fontSize: 13.28, // 0.83
              fontWeight: FontWeight.bold,
            ),
          ),
      "h6": (element) => Text(
            element.text,
            style: TextStyle(
              fontSize: 10.72, // 0.67
              fontWeight: FontWeight.bold,
            ),
          ),
    };
  }

  Map<String, Widget Function(Element element)> textTag() {
    return {
      "code": (element) => Text(
            element.text,
            style: TextStyle(fontFamily: "monospace"),
          ),
      "strong": (element) => Text(
            element.text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
      "b": (element) => Text(
            element.text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
      "i": (element) => Text(
            element.text,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
      "em": (element) => Text(
            element.text,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
      "blockquote": (element) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              element.text,
              style: TextStyle(),
            ),
          ),
      "ol": (element) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: element
                .querySelectorAll("li")
                .toList()
                .asMap()
                .entries
                .map(
                  (entry) => Text("${entry.key + 1}. ${entry.value.text}"),
                )
                .toList(),
          ),
      "ul": (element) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: element
                .querySelectorAll("li")
                .toList()
                .asMap()
                .entries
                .map(
                  (entry) => Text("• ${entry.value.text}"),
                )
                .toList(),
          ),
      "a": (element) => MouseRegion(
            cursor: SystemMouseCursors.click,
            child: BlocBuilder<BrowserCubit, BrowserState>(
                builder: (context, state) {
              return GestureDetector(
                onTap: () {
                  final href = element.attributes["href"]!;

                  Uri uri;
                  if (href.startsWith('/') ||
                      href.startsWith('./') ||
                      !href.contains('://')) {
                    // Relative link
                    uri =
                        Uri.parse(state.currentTab!.history.last.uri.toString())
                            .resolve(href);
                  } else {
                    // Assume absolute URI
                    uri = Uri.parse(href);
                  }

                  context.read<BrowserCubit>().visitUri(uri);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      element.text,
                      style: TextStyle(
                        color: Colors.blue,
                        decorationColor: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
              );
            }),
          ),
    };
  }

  Map<String, Widget Function(Element element)> actionTags() {
    return {
      "img": (e) => Image.network(
            e.attributes["src"]!,
            semanticLabel: e.attributes["alt"],
          ),
      "table": (e) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: e.children
                .map(
                  (child) => parse(child),
                )
                .toList(),
          ),
      "thead": (e) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: e.children
                .map(
                  (child) => parse(child),
                )
                .toList(),
          ),
      "tbody": (e) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: e.children
                .map(
                  (child) => parse(child),
                )
                .toList(),
          ),
      "tr": (e) => Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: e.children
                .map(
                  (child) => parse(child),
                )
                .toList(),
          ),
      "th": (e) => Text(
            e.text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
      "td": (e) => Text(e.text),
    };
  }

  Widget parse(Element? elementToParse) {
    if (elementToParse == null) {
      return SizedBox.shrink();
    }

    final tags = <String?, Widget Function(Element element)>{
      ...headerTag(),
      ...textTag(),
      ...actionTags(),
      ...structureTag(),
      null: (element) => Text(element.text),
    };

    final localName = elementToParse.localName;
    if (tags.containsKey(localName)) {
      return tags[localName]!(elementToParse);
    } else {
      return tags[null]!(elementToParse);
    }
    // return elementToParse.children.map<Widget>((child) {
    //   final localName = child.localName;
    //   if (tags.containsKey(localName)) {
    //     return tags[localName]!(child);
    //   } else {
    //     return tags[null]!(child);
    //   }
    // }).toList(); // Flatten at each level
  }
}
