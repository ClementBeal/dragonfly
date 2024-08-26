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
      "max-width": (String value) => style.maxWidth = value,
      "padding": (String value) => _applyPadding(style, value),
      "text-align": (String value) => style.textAlign = value,
      "font-size": (String value) => style.fontSize = value,
      "font-weight": (String value) => style.fontWeight = value,
      "display": (String value) => style.display = value,
      "border-radius": (String value) => style.borderRadius = value,
      "border-left": (String value) => style.borderLeft = value,
      "border-right": (String value) => style.borderRight = value,
      "border-top": (String value) => style.borderTop = value,
      "border-bottom": (String value) => style.borderBottom = value,
      "gap": (String value) => style.gap = value,
      "border": (String value) => style.border = value,
      "justify-content": (String value) => style.justifyContent = value,
      "align-items": (String value) => style.alignItems = value,
      "min-height": (String value) => style.minHeight = value,
      "font-family": (String value) => style.fontFamily = value,
    };

    final handler = propertyHandlers[declaration.property];
    if (handler != null) {
      handler(declaration.value);
    }
  }

  void _applyMargin(CssStyle style, String value) {
    final tokens = value.split(" ");
    if (tokens.length == 1 && value == "auto") {
      style.marginTop = value;
      style.marginBottom = value;
      style.marginLeft = value;
      style.marginRight = value;
    } else if (tokens.length == 1) {
      style.marginTop = value;
      style.marginBottom = value;
      style.marginLeft = value;
      style.marginRight = value;
    }
  }

  void _applyPadding(CssStyle style, String value) {
    final tokens = value.split(" ");
    if (tokens.length == 2) {
      style.paddingTop = tokens[0];
      style.paddingBottom = tokens[0];
      style.paddingLeft = tokens[1];
      style.paddingRight = tokens[1];
    }
  }
}
