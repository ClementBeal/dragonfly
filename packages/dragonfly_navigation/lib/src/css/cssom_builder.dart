import 'package:collection/collection.dart';
import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';

abstract class CssomNode {}

class CssomTree extends CssomNode {
  final List<CSSRule> rules;

  CssomTree({required this.rules});

  CSSRule? find(String selector) {
    return rules.firstWhereOrNull(
      (rule) => rule.selector == selector,
    );
  }

  void addChild(CSSRule cssRule) {
    rules.add(cssRule);
  }

  void visit(Function(CSSRule rule) ruleEditer) {
    for (var rule in rules) {
      ruleEditer(rule);
    }
  }
}

class CSSRule extends CssomNode {
  final String selector;
  final CssStyle style;

  CSSRule({required this.selector, required this.style});
}

class CssomBuilder {
  CssomTree? browserStyle;

  void loadBrowserStyle(String css) {
    browserStyle = parse(css);
  }

  /// First, we parse a CSS file and extract the rules (e.g: body {margin: 8px; })
  /// Then we start to build a CSSOM tree
  /// it musts use the browser CSSOM if available
  /// otherwise, it create it from scratch
  ///
  CssomTree parse(String css) {
    final document = CssParser().parse(css);

    final tree = browserStyle ?? CssomTree(rules: []);

    for (var rule in document.rules) {
      final selector = rule.selector;
      final cssRule = tree.find(selector);
      // if we alreay have the rule style, we use it
      // else we use an empty one
      // it's important because the browser has default style
      // for h1 or p por instance
      final newStyle = cssRule?.style ?? CssStyle();

      for (var declaration in rule.declarations) {
        if (declaration.property == "color") {
          newStyle.textColor = declaration.value;
        } else if (declaration.property == "background-color") {
          newStyle.backgroundColor = declaration.value;
        } else if (declaration.property == "text-decoration") {
          newStyle.textDecoration = declaration.value;
        } else if (declaration.property == "margin") {
          final tokens = declaration.value.split(" ");

          if (tokens.length == 1 && declaration.value == "auto") {
            newStyle.marginBottom = declaration.value;
            newStyle.marginLeft = declaration.value;
            newStyle.marginTop = declaration.value;
            newStyle.marginRight = declaration.value;
          } else if (tokens.length == 1) {
            newStyle.marginBottom = declaration.value;
            newStyle.marginLeft = declaration.value;
            newStyle.marginTop = declaration.value;
            newStyle.marginRight = declaration.value;
          }
        } else if (declaration.property == "max-width") {
          newStyle.maxWidth = declaration.value;
        } else if (declaration.property == "padding") {
          final tokens = declaration.value.split(" ");
          if (tokens.length == 2) {
            newStyle.paddingTop = tokens[0];
            newStyle.paddingBottom = tokens[0];
            newStyle.paddingLeft = tokens[1];
            newStyle.paddingRight = tokens[1];
          }
        } else if (declaration.property == "text-align") {
          newStyle.textAlign = declaration.value;
        } else if (declaration.property == "font-size") {
          newStyle.fontSize = declaration.value;
        } else if (declaration.property == "font-weight") {
          newStyle.fontWeight = declaration.value;
        } else if (declaration.property == "display") {
          newStyle.display = declaration.value;
        } else if (declaration.property == "border-radius") {
          newStyle.borderRadius = declaration.value;
        } else if (declaration.property == "border-left") {
          newStyle.borderLeft = declaration.value;
        } else if (declaration.property == "border-right") {
          newStyle.borderRight = declaration.value;
        } else if (declaration.property == "border-top") {
          newStyle.borderTop = declaration.value;
        } else if (declaration.property == "border-bottom") {
          newStyle.borderBottom = declaration.value;
        } else if (declaration.property == "margin-left") {
          newStyle.marginLeft = declaration.value;
        } else if (declaration.property == "margin-right") {
          newStyle.marginRight = declaration.value;
        } else if (declaration.property == "margin-top") {
          newStyle.marginTop = declaration.value;
        } else if (declaration.property == "margin-bottom") {
          newStyle.marginBottom = declaration.value;
        } else if (declaration.property == "gap") {
          newStyle.gap = declaration.value;
        } else if (declaration.property == "border") {
          newStyle.border = declaration.value;
        } else if (declaration.property == "justify-content") {
          newStyle.justifyContent = declaration.value;
        } else if (declaration.property == "align-items") {
          newStyle.alignItems = declaration.value;
        } else if (declaration.property == "min-height") {
          newStyle.minHeight = declaration.value;
        } else if (declaration.property == "font-family") {
          newStyle.fontFamily = declaration.value;
        }
      }

      if (selector == "*") {
        tree.visit((node) => node.style.mergeClass(newStyle));
      } else {
        if (cssRule == null) {
          tree.addChild(CSSRule(selector: selector, style: newStyle));
        } else {
          cssRule.style.mergeClass(newStyle);
        }
      }
    }

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
    this.fontFamily,
  });

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
  String? fontFamily;

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
    fontFamily = newTheme.fontFamily ?? fontFamily;
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
    fontFamily = (fontFamily == null) ? newTheme.fontFamily : fontFamily;
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
fontFamily: $fontFamily
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
      fontFamily: fontFamily,
    );
  }
}
