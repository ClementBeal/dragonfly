import 'package:dragonfly/browser/css/css_parser.dart';

enum HTMLTag { html, head, body }

class CSSOM {
  HTMLTag htmlTag;
  CssStyle data;
  late List<CSSOM> children;

  CSSOM(this.htmlTag, this.data) {
    children = [];
  }

  // Add a child node
  void addChild(CSSOM child) {
    children.add(child);
  }

  // Remove a child node
  void removeChild(CSSOM child) {
    children.remove(child);
  }

  // Check if the node has children
  bool hasChildren() {
    return children.isNotEmpty;
  }

  CSSOM? find(HTMLTag tag) {
    if (htmlTag == tag) return this;

    for (var child in children) {
      if (child.htmlTag == tag) return child;

      final childOutput = child.find(tag);

      if (child.find(tag) != null) return childOutput;
    }

    return null;
  }

  @override
  String toString() {
    return _toStringHelper(this, "");
  }

  // Recursive helper function for pretty-printing the tree
  String _toStringHelper(CSSOM node, String prefix) {
    if (node == null) return "";
    String result = "$prefix${node.data}\n";
    for (int i = 0; i < node.children.length; i++) {
      result += _toStringHelper(node.children[i],
          "$prefix${i == node.children.length - 1 ? "└── " : "├── "}");
    }
    return result;
  }
}

class CssomBuilder {
  CSSOM parse(String css) {
    final document = CssParser(css).parse();
    print(document);

    final tree = CSSOM(HTMLTag.html, CssStyle.initial())
      ..addChild(CSSOM(HTMLTag.head, CssStyle.initial()))
      ..addChild(CSSOM(
          HTMLTag.body,
          CssStyle(
            marginTop: 9,
            marginBottom: 9,
            marginLeft: 9,
            marginRight: 9,
          )));

    // for (var child in document.topLevels) {
    //   final tag = child.span?.text;

    //   if (tag == "body") {
    //     final body = tree.find(HTMLTag.body);
    //     print(child.span?.length);
    //     print(child.span?.text);
    //     print(child.span?.start);
    //     print(child.span?.end);
    //     if (body == null) {
    //       tree.addChild(CSSOM(HTMLTag.body, CssStyle()));
    //     } else {
    //       body.data.copyWith();
    //     }
    //   }
    // }

    return tree;
  }
}

class CssStyle {
  CssStyle(
      {this.marginTop,
      this.marginBottom,
      this.marginLeft,
      this.marginRight,
      this.lineHeight,
      this.backgroundColor,
      this.textColor});

  CssStyle.initial()
      : lineHeight = 1.0,
        backgroundColor = null,
        textColor = "#000000",
        marginTop = 0,
        marginBottom = 0,
        marginLeft = 0,
        marginRight = 0;

  final double? lineHeight;
  final String? backgroundColor;
  final String? textColor;
  final double? marginTop;
  final double? marginBottom;
  final double? marginLeft;
  final double? marginRight;

  CssStyle copyWith({
    double? lineHeight,
    String? backgroundColor,
    String? textColor,
  }) {
    return CssStyle(
      lineHeight: lineHeight ?? this.lineHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      // margin: margin ?? this.margin,
    );
  }
}
