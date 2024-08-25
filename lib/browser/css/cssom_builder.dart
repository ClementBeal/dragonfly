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
        ..addChild(CSSOM("a", CssStyle.a()))
        ..addChild(CSSOM("ul", CssStyle.ul()))
        ..addChild(CSSOM("div", CssStyle.div()))
        ..addChild(CSSOM("p", CssStyle.p()))
        ..addChild(CSSOM("h1", CssStyle.h1()))
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
    String result = "${node.htmlTag}\n$prefix${node.data}\n";

    for (int i = 0; i < node.children.length; i++) {
      result += _toStringHelper(node.children[i],
          "$prefix${i == node.children.length - 1 ? "└── " : "├── "}");
    }

    return result;
  }

  void visit(Function(CSSOM node) onVisit) {
    onVisit(this);
    for (var child in children) {
      child.visit(onVisit);
    }
  }
}

class CssomBuilder {
  CSSOM parse(String css) {
    final document = CssParser(css).parse();

    final tree = CSSOM.initial();

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
          final tokens = declaration.value.split(" ");

          if (tokens.length == 1 && declaration.value == "auto") {
            newTheme.marginBottom = declaration.value;
            newTheme.marginLeft = declaration.value;
            newTheme.marginTop = declaration.value;
            newTheme.marginRight = declaration.value;
          } else if (tokens.length == 1) {
            newTheme.marginBottom = declaration.value;
            newTheme.marginLeft = declaration.value;
            newTheme.marginTop = declaration.value;
            newTheme.marginRight = declaration.value;
          }
        } else if (declaration.property == "max-width") {
          newTheme.maxWidth = declaration.value;
        } else if (declaration.property == "padding") {
          final tokens = declaration.value.split(" ");
          if (tokens.length == 2) {
            newTheme.paddingTop = tokens[0];
            newTheme.paddingBottom = tokens[0];
            newTheme.paddingLeft = tokens[1];
            newTheme.paddingRight = tokens[1];
          }
        } else if (declaration.property == "text-align") {
          newTheme.textAlign = declaration.value;
        } else if (declaration.property == "font-size") {
          newTheme.fontSize = declaration.value;
        } else if (declaration.property == "font-weight") {
          newTheme.fontWeight = declaration.value;
        } else if (declaration.property == "display") {
          newTheme.display = declaration.value;
        } else if (declaration.property == "border-radius") {
          newTheme.borderRadius = declaration.value;
        } else if (declaration.property == "border-left") {
          newTheme.borderLeft = declaration.value;
        } else if (declaration.property == "border-right") {
          newTheme.borderRight = declaration.value;
        } else if (declaration.property == "border-top") {
          newTheme.borderTop = declaration.value;
        } else if (declaration.property == "border-bottom") {
          newTheme.borderBottom = declaration.value;
        } else if (declaration.property == "margin-left") {
          newTheme.marginLeft = declaration.value;
        } else if (declaration.property == "margin-right") {
          newTheme.marginRight = declaration.value;
        } else if (declaration.property == "margin-top") {
          newTheme.marginTop = declaration.value;
        } else if (declaration.property == "margin-bottom") {
          newTheme.marginBottom = declaration.value;
        } else if (declaration.property == "gap") {
          newTheme.gap = declaration.value;
        } else if (declaration.property == "border") {
          newTheme.border = declaration.value;
        } else if (declaration.property == "justify-content") {
          newTheme.justifyContent = declaration.value;
        } else if (declaration.property == "align-items") {
          newTheme.alignItems = declaration.value;
        } else if (declaration.property == "min-height") {
          newTheme.minHeight = declaration.value;
        }
      }

      if (tag == "*") {
        print("le star");
        tree.visit((node) => node.data.mergeClass(newTheme));
      } else {
        final style = tree.find(tag);
        final styleClass = tree.find(".$tag");

        if (style == null) {
          tree.addChild(CSSOM(tag, newTheme));
        } else if (styleClass != null) {
          styleClass.data.merge(newTheme);
        } else {
          style.data.mergeClass(newTheme);
        }
      }
    }

    // print(tree);

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
    this.fontSize,
    this.fontWeight,
    this.textDecoration,
    this.textAlign,
    this.listStyleType,
    this.paddingTop,
    this.paddingBottom,
    this.paddingLeft,
    this.paddingRight,
    this.maxWidth,
    this.maxHeight,
    this.isCentered,
    this.display,
    this.borderRadius,
    this.borderLeft,
    this.borderRight,
    this.borderTop,
    this.borderBottom,
    this.gap,
    this.border,
    this.justifyContent,
    this.alignItems,
    this.minHeight,
  });

  CssStyle.initial()
      : lineHeight = 1.0,
        backgroundColor = null,
        fontSize = "16px";

  CssStyle.body()
      : marginBottom = "8px",
        marginLeft = "8px",
        marginTop = "8px",
        marginRight = "8px";
  CssStyle.h1()
      : fontWeight = "bold",
        marginTop = "0.67rem",
        marginBottom = "0.67rem",
        fontSize = "2rem";
  CssStyle.h2()
      : fontWeight = "bold",
        marginTop = "0.83rem",
        marginBottom = "0.83rem",
        fontSize = "1.5rem";
  CssStyle.h3()
      : fontWeight = "bold",
        marginTop = "1rem",
        marginBottom = "1rem",
        fontSize = "1.17rem";
  CssStyle.a()
      : textColor = "#00F",
        textDecoration = "underline";
  CssStyle.p()
      : textColor = "#000000",
        marginTop = "1em",
        marginBottom = "1em";
  CssStyle.ul()
      : listStyleType = "disc",
        marginTop = "1em",
        marginBottom = "1em",
        paddingLeft = "40px";
  CssStyle.div();

  double? lineHeight;
  String? backgroundColor;
  String? textColor;
  String? marginTop;
  String? marginBottom;
  String? marginLeft;
  String? marginRight;
  String? paddingTop;
  String? paddingBottom;
  String? paddingLeft;
  String? paddingRight;
  String? maxWidth;
  String? maxHeight;
  bool? isCentered;
  String? fontSize;
  String? fontWeight;
  String? textDecoration;
  String? textAlign;
  String? listStyleType;
  String? display;
  String? borderRadius;
  String? borderLeft;
  String? borderRight;
  String? borderTop;
  String? borderBottom;
  String? gap;
  String? border;
  String? justifyContent;
  String? alignItems;
  String? minHeight;

  CssStyle copyWith({
    double? lineHeight,
    String? backgroundColor,
    String? textColor,
  }) {
    return CssStyle(
      lineHeight: lineHeight ?? this.lineHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
    );
  }

  void merge(CssStyle newTheme) {
    lineHeight = newTheme.lineHeight ?? lineHeight;
    textColor = newTheme.textColor ?? textColor;
    textDecoration = newTheme.textDecoration ?? textDecoration;
    textAlign = newTheme.textAlign ?? textAlign;
    fontWeight = newTheme.fontWeight ?? fontWeight;
    fontSize = newTheme.fontSize ?? fontSize;
  }

  void mergeClass(CssStyle newTheme) {
    merge(newTheme);
    backgroundColor = newTheme.backgroundColor ?? backgroundColor;

    marginTop = newTheme.marginTop ?? marginTop;
    marginBottom = newTheme.marginBottom ?? marginBottom;
    marginLeft = newTheme.marginLeft ?? marginLeft;
    marginRight = newTheme.marginRight ?? marginRight;

    paddingTop = newTheme.paddingTop ?? paddingTop;
    paddingBottom = newTheme.paddingBottom ?? paddingBottom;
    paddingLeft = newTheme.paddingLeft ?? paddingLeft;
    paddingRight = newTheme.paddingRight ?? paddingRight;

    maxWidth = newTheme.maxWidth ?? maxWidth;
    minHeight = newTheme.minHeight ?? minHeight;

    display = newTheme.display ?? display;
    borderRadius = newTheme.borderRadius ?? borderRadius;

    borderLeft = newTheme.borderLeft ?? borderLeft;
    borderRight = newTheme.borderRight ?? borderRight;
    borderTop = newTheme.borderTop ?? borderTop;
    borderBottom = newTheme.borderBottom ?? borderBottom;
    border = newTheme.border ?? border;

    gap = newTheme.gap ?? gap;
    justifyContent = newTheme.justifyContent ?? justifyContent;
    alignItems = newTheme.alignItems ?? alignItems;
  }

  void inheritFromParent(CssStyle newTheme) {
    // inherited only if the rule is not set
    lineHeight = (lineHeight == null) ? newTheme.lineHeight : lineHeight;
    textColor = (textColor == null) ? newTheme.textColor : textColor;
    textDecoration =
        (textDecoration == null) ? newTheme.textDecoration : textDecoration;
    textAlign = (textAlign == null) ? newTheme.textAlign : textAlign;
    fontWeight = (fontWeight == null) ? newTheme.fontWeight : fontWeight;
    fontSize = (fontSize == null) ? newTheme.fontSize : fontSize;
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
paddingLeft: $paddingLeft
paddingBottom: $paddingBottom
paddingRight: $paddingRight
paddingTop: $paddingTop
textDecoration: $textDecoration
textAlign: $textAlign
maxWidth: $maxWidth
borderLeft: $borderLeft
borderRight: $borderRight
borderTop: $borderTop
borderBottom: $borderBottom
gap: $gap
border: $border
justifyContent: $justifyContent
alignItmes: $alignItems
minHeight: $minHeight
""";
  }

  CssStyle clone() {
    return CssStyle(
      marginTop: marginTop,
      marginBottom: marginBottom,
      marginLeft: marginLeft,
      marginRight: marginRight,
      lineHeight: lineHeight,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      textDecoration: textDecoration,
      textAlign: textAlign,
      listStyleType: listStyleType,
      paddingTop: paddingTop,
      paddingBottom: paddingBottom,
      paddingLeft: paddingLeft,
      paddingRight: paddingRight,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      isCentered: isCentered,
      display: display,
      borderRadius: borderRadius,
      borderLeft: borderLeft,
      borderRight: borderRight,
      borderTop: borderTop,
      borderBottom: borderBottom,
      gap: gap,
      border: border,
      justifyContent: justifyContent,
      alignItems: alignItems,
      minHeight: minHeight,
    );
  }
}
