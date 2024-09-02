import 'package:collection/collection.dart';
import 'package:dragonfly_css_parser/dragonfly_css_parser.dart';
import 'package:dragonfly_navigation/src/css/css_style.dart';

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

  // Method to clone the CssomTree
  CssomTree clone() {
    // Clone each CSSRule in the list
    List<CSSRule> clonedRules = rules.map((rule) => rule.clone()).toList();
    return CssomTree(rules: clonedRules);
  }
}

class CSSRule extends CssomNode {
  final String selector;
  final CssStyle style;

  CSSRule({required this.selector, required this.style});

  // Method to clone the CSSRule
  CSSRule clone() {
    return CSSRule(
      selector: selector,
      style: style.clone(), // Assuming CssStyle has a clone method
    );
  }
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
  CssomTree parse(String css) {
    final document = CssParser().parse(css);
    final tree = browserStyle?.clone() ?? CssomTree(rules: []);

    for (var rule in document.rules) {
      final selector = rule.selector;
      final cssRule = tree.find(selector);
      final newStyle = cssRule?.style ?? CssStyle();

      for (var declaration in rule.declarations) {
        _applyDeclaration(newStyle, declaration);
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

  void _applyDeclaration(CssStyle style, Declaration declaration) {
    final propertyHandlers = {
      "color": (String value) => style.textColor = value,
      "background-color": (String value) => style.backgroundColor = value,
      "text-decoration": (String value) => style.textDecoration = value,
      "margin": (String value) => _applyMargin(style, value),
      "margin-left": (String value) => style.marginLeft = value,
      "margin-top": (String value) => style.marginTop = value,
      "margin-right": (String value) => style.marginRight = value,
      "margin-bottom": (String value) => style.marginBottom = value,
      "max-width": (String value) => style.maxWidth = value,
      "padding": (String value) => _applyPadding(style, value),
      "padding-left": (String value) => style.paddingLeft = value,
      "padding-top": (String value) => style.paddingTop = value,
      "padding-right": (String value) => style.paddingRight = value,
      "padding-bottom": (String value) => style.paddingBottom = value,
      "text-align": (String value) => style.textAlign = value,
      "font-size": (String value) => style.fontSize = value,
      "font-weight": (String value) => style.fontWeight = value,
      "display": (String value) => style.display = value,
      "border-radius": (String value) => style.borderRadius = value,
      "border-left": (String value) {
        final tokens = value.split(" ");
        style.borderLeftColor = tokens[2];
        style.borderLeftWidth = tokens[0];
      },
      "border-right": (String value) {
        final tokens = value.split(" ");
        style.borderRightColor = tokens[2];
        style.borderRightWidth = tokens[0];
      },
      "border-top": (String value) {
        final tokens = value.split(" ");
        style.borderTopColor = tokens[2];
        style.borderTopWidth = tokens[0];
      },
      "border-bottom": (String value) {
        final tokens = value.split(" ");
        style.borderBottomColor = tokens[2];
        style.borderBottomWidth = tokens[0];
      },
      "background": (String value) {
        final tokens = value.split(" ");

        if (tokens.length == 1) {
          style.backgroundColor = tokens[0];
        }
      },
      "gap": (String value) => style.gap = value,
      "border": (String value) => style.border = value,
      "justify-content": (String value) => style.justifyContent = value,
      "align-items": (String value) => style.alignItems = value,
      "min-height": (String value) => style.minHeight = value,
      "font-family": (String value) => style.fontFamily = value,
      "list-style-type": (String value) => style.listStyleType = value,
    };

    final handler = propertyHandlers[declaration.property];
    if (handler != null) {
      handler(declaration.value);
    }
  }

  void _applyMargin(CssStyle style, String value) {
    final tokens = value.split(" ");

    if (tokens.length == 1 && value == "auto") {
      style.isCentered = true;
    } else if (tokens.length == 1) {
      style.marginTop = value;
      style.marginBottom = value;
      style.marginLeft = value;
      style.marginRight = value;
    } else if (tokens.length == 2) {
      style.marginTop = tokens[0];
      style.marginBottom = tokens[0];
      style.marginLeft = tokens[1];
      style.marginRight = tokens[1];
    } else if (tokens.length == 3) {
      style.marginTop = tokens[0];
      style.marginLeft = tokens[1];
      style.marginRight = tokens[1];
      style.marginBottom = tokens[2];
    } else if (tokens.length == 4) {
      style.marginTop = tokens[0];
      style.marginRight = tokens[1];
      style.marginBottom = tokens[2];
      style.marginLeft = tokens[3];
    }
  }

  void _applyPadding(CssStyle style, String value) {
    final tokens = value.split(" ");

    if (tokens.length == 1) {
      style.paddingTop = value;
      style.paddingBottom = value;
      style.paddingLeft = value;
      style.paddingRight = value;
    } else if (tokens.length == 2) {
      style.paddingTop = tokens[0];
      style.paddingBottom = tokens[0];
      style.paddingLeft = tokens[1];
      style.paddingRight = tokens[1];
    } else if (tokens.length == 3) {
      style.paddingTop = tokens[0];
      style.paddingLeft = tokens[1];
      style.paddingRight = tokens[1];
      style.paddingBottom = tokens[2];
    } else if (tokens.length == 4) {
      style.paddingTop = tokens[0];
      style.paddingRight = tokens[1];
      style.paddingBottom = tokens[2];
      style.paddingLeft = tokens[3];
    }
  }
}
