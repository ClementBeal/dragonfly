import 'package:dragonfly/browser/css/css_parser.dart';

class CSSOM {
  String htmlTag;
  CssStyle data;
  late List<CSSOM> children;

  CSSOM(this.htmlTag, this.data) {
    children = [];
  }

  factory CSSOM.initial() => CSSOM("html", CssStyle.initial())
    ..addChild(CSSOM("head", CssStyle.initial()))
    ..addChild(
      CSSOM("body", CssStyle.body())
        ..addChild(CSSOM("h1", CssStyle.h1()))
        ..addChild(CSSOM("a", CssStyle.a()))
        ..addChild(CSSOM("h2", CssStyle.h2()))
        ..addChild(CSSOM("h3", CssStyle.h3())),
    );

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

  CSSOM? find(String tag) {
    if (htmlTag == tag) return this;

    for (var child in children) {
      if (child.htmlTag == tag) return child;

      final childOutput = child.find(tag);

      if (childOutput != null) return childOutput;
    }

    return null;
  }

  @override
  String toString() {
    return _toStringHelper(this, "");
  }

  // Recursive helper function for pretty-printing the tree
  String _toStringHelper(CSSOM node, String prefix) {
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

    final tree = CSSOM("html", CssStyle.initial())
      ..addChild(CSSOM("head", CssStyle.initial()))
      ..addChild(
        CSSOM("body", CssStyle.body())
          ..addChild(CSSOM("h1", CssStyle.h1()))
          ..addChild(CSSOM("a", CssStyle.a()))
          ..addChild(CSSOM("h2", CssStyle.h2()))
          ..addChild(CSSOM("h3", CssStyle.h3())),
      );

    for (var rule in document.rules) {
      final tag = rule.selector;
      final newTheme = CssStyle.initial();

      for (var declaration in rule.declarations) {
        if (declaration.property == "color") {
          newTheme.textColor = declaration.value;
        } else if (declaration.property == "background-color") {
          newTheme.backgroundColor = declaration.value;
        } else if (declaration.property == "text-decoration") {
          newTheme.textDecoration = declaration.value;
        } else if (declaration.property == "margin") {
          if (declaration.value == "auto") {
            newTheme.marginBottom = declaration.value;
            newTheme.marginLeft = declaration.value;
            newTheme.marginTop = declaration.value;
            newTheme.marginRight = declaration.value;
          }
        } else if (declaration.property == "max-width") {
          newTheme.maxWidth = declaration.value;
        }
      }

      final style = tree.find(tag);

      print(tag);

      if (style == null) {
        tree.addChild(CSSOM(tag, CssStyle.initial()..merge(newTheme)));
      } else {
        style.data.merge(newTheme);
      }
    }

    print(tree);

    return tree;
  }
}

class CssStyle {
  CssStyle({
    this.marginTop,
    this.marginBottom,
    this.marginLeft,
    this.marginRight,
    this.lineHeight,
    this.backgroundColor,
    this.textColor,
    this.fontSize = "16px",
  });

  CssStyle.initial()
      : lineHeight = 1.0,
        backgroundColor = null,
        textColor = "#000000",
        fontSize = "12px";

  CssStyle.body()
      : marginBottom = "8px",
        marginLeft = "8px",
        marginTop = "8px",
        marginRight = "8px";
  CssStyle.h1()
      : fontWeight = "bold",
        marginLeft = "0.67rem",
        marginRight = "0.67rem",
        fontSize = "2rem";
  CssStyle.h2()
      : fontWeight = "bold",
        marginLeft = "0.83rem",
        marginRight = "0.83rem",
        fontSize = "1.5rem";
  CssStyle.h3()
      : fontWeight = "bold",
        marginLeft = "1rem",
        marginRight = "1rem",
        fontSize = "1.17rem";
  CssStyle.a()
      : marginLeft = "1rem",
        marginRight = "1rem",
        textColor = "#00F",
        textDecoration = "underline";

  double? lineHeight;
  String? backgroundColor;
  String? textColor;
  String? marginTop;
  String? marginBottom;
  String? marginLeft;
  String? marginRight;
  String? maxWidth;
  String? maxHeight;
  bool? isCentered;
  String? fontSize;
  String? fontWeight;
  String? textDecoration;

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

  void merge(CssStyle newTheme) {
    lineHeight = newTheme.lineHeight ?? lineHeight;
    backgroundColor = newTheme.backgroundColor ?? backgroundColor;
    textColor = newTheme.textColor ?? textColor;
    marginTop = newTheme.marginTop ?? marginTop;
    marginBottom = newTheme.marginBottom ?? marginBottom;
    marginLeft = newTheme.marginLeft ?? marginLeft;
    marginRight = newTheme.marginRight ?? marginRight;
    textDecoration = newTheme.textDecoration ?? textDecoration;
  }

  @override
  String toString() {
    return """
textColor: $textColor
backgroundColor: $backgroundColor
fontSize: $fontSize
fontWeight: $fontWeight
marginLeft: $marginLeft
marginBottom: $marginBottom
marginRight: $marginRight
marginTop: $marginTop
textDecoration: $textDecoration
""";
  }
}
