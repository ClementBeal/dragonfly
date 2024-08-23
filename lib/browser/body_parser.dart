/*
 HML5 specs -> https://www.w3.org/TR/2012/WD-html-markup-20121025/Overview.html#toc
*/

import 'package:dragonfly/browser/page.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/dom.dart' hide Text;

class BodyParser {
  Map<String, Widget Function(Element element)> structureTag() {
    return {
      "body": (e) => Column(
            mainAxisSize: MainAxisSize.min,
            children: e.children.map((child) => parse(child)).toList(),
          ),
      "nav": (e) => Row(
            mainAxisSize: MainAxisSize.min,
            children: e.children.map((child) => parse(child)).toList(),
          ),
      "header": (e) => Flex(
            direction: Axis.vertical,
            children: e.children.map((child) => parse(child)).toList(),
          ),
      "div": (e) {
        return Flex(
          direction: Axis.vertical,
          children: e.children.map((child) => parse(child)).toList(),
        );
      },
      "main": (e) => Flex(
            direction: Axis.vertical,
            children: e.children.map((child) => parse(child)).toList(),
          ),
    };
  }

  Map<String, Widget Function(Element element)> headerTag() {
    return {
      "h1": (element) => Text(
            element.text,
            style: const TextStyle(
              fontSize: 32, // 2.0
              fontWeight: FontWeight.bold,
            ),
          ),
      "h2": (element) => Text(
            element.text,
            style: const TextStyle(
              fontSize: 24, // 1.5
              fontWeight: FontWeight.bold,
            ),
          ),
      "h3": (element) => Text(
            element.text,
            style: const TextStyle(
              fontSize: 18.72, // 1.17
              fontWeight: FontWeight.bold,
            ),
          ),
      "h4": (element) => Text(
            element.text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
      "h5": (element) => Text(
            element.text,
            style: const TextStyle(
              fontSize: 13.28, // 0.83
              fontWeight: FontWeight.bold,
            ),
          ),
      "h6": (element) => Text(
            element.text,
            style: const TextStyle(
              fontSize: 10.72, // 0.67
              fontWeight: FontWeight.bold,
            ),
          ),
    };
  }

  Map<String, Widget Function(Element element)> textTag() {
    return {
      "small": (element) => Text(
            element.text,
            style: const TextStyle(fontSize: 12),
          ),
      "code": (element) => Text(
            element.text,
            style: const TextStyle(fontFamily: "monospace"),
          ),
      "strong": (element) => Text(
            element.text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
      "b": (element) => Text(
            element.text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
      "i": (element) => Text(
            element.text,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
      "em": (element) => Text(
            element.text,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
      "blockquote": (element) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              element.text,
              style: const TextStyle(),
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
                child: Wrap(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      element.text,
                      style: const TextStyle(
                        color: Colors.blue,
                        decorationColor: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    ...element.children.map((child) => parse(child)),
                  ],
                ),
              );
            }),
          ),
    };
  }

  Map<String, Widget Function(Element element)> actionTags() {
    return {
      "img": (e) {
        print("got images");
        final image = Favicon(href: e.attributes["src"]!);
        final alt = e.attributes["alt"];

        print(image.type);

        return switch (image.type) {
          FaviconType.unknown || null => Container(
              color: Colors.red,
              width: 50,
              height: 50,
            ),
          FaviconType.url => Image.network(image.href),
          FaviconType.png ||
          FaviconType.ico ||
          FaviconType.jpeg ||
          FaviconType.gif =>
            Image.memory(image.decodeBase64()!),
          FaviconType.svg => SvgPicture.memory(
              image.decodeBase64()!,
              height: 120,
              width: 120,
            ),
        };
      },
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
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
      "td": (e) => Text(e.text),
    };
  }

  Widget parse(Element? elementToParse) {
    if (elementToParse == null) {
      return const SizedBox.shrink();
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
