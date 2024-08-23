import 'package:dragonfly/browser/dom/html_node.dart';
import 'package:flutter/material.dart';

enum ListDecoration { disc, number, none }

class CssTheme {
  CssTheme({
    this.fontSize = const FontSize(type: FontSizeType.px, value: 16),
    this.textColor = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.margin = EdgeInsets.zero,
    this.textDecoration,
    this.listDecoration = ListDecoration.none,
    this.lineHeight = 1.0,
    required this.customTagTheme,
  });

  final FontSize fontSize;
  final Color textColor;
  final FontWeight fontWeight;
  final EdgeInsets margin;
  final TextDecoration? textDecoration;
  final ListDecoration listDecoration;
  final Map<Type, CssTheme> customTagTheme;
  final double lineHeight;

  CssTheme copyWith({
    FontSize? fontSize,
    Color? textColor,
    FontWeight? fontWeight,
    EdgeInsets? margin,
    TextDecoration? Function()? textDecoration,
    ListDecoration? listDecoration,
    double? lineHeight,
  }) =>
      CssTheme(
        fontSize: fontSize ?? this.fontSize,
        textColor: textColor ?? this.textColor,
        fontWeight: fontWeight ?? this.fontWeight,
        margin: margin ?? this.margin,
        textDecoration:
            textDecoration != null ? textDecoration() : this.textDecoration,
        listDecoration: listDecoration ?? this.listDecoration,
        customTagTheme: customTagTheme,
        lineHeight: lineHeight ?? this.lineHeight,
      );

  CssTheme getStyleForNode(DomNode node) {
    if (node is BodyNode) {
      return copyWith(
          fontSize: fontSize.getValue(FontSizeType.px, 16),
          margin: EdgeInsets.all(8));
    }
    if (node is H1Node) {
      return copyWith(
        fontSize: fontSize.getValue(FontSizeType.rem, 2.0),
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(
          vertical: fontSize.getValue(FontSizeType.rem, 0.67).value,
        ),
      );
    }
    if (node is H2Node) {
      return copyWith(
        fontSize: fontSize.getValue(FontSizeType.rem, 1.5),
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(
          vertical: fontSize.getValue(FontSizeType.rem, 0.83).value,
        ),
      );
    }
    if (node is H3Node) {
      return copyWith(
        fontSize: fontSize.getValue(FontSizeType.rem, 1.17),
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(
          vertical: fontSize.getValue(FontSizeType.rem, 1.0).value,
        ),
      );
    }
    if (node is H4Node) {
      return copyWith(
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(
          vertical: fontSize.getValue(FontSizeType.rem, 1.33).value,
        ),
      );
    }
    if (node is H5Node) {
      return copyWith(
        fontSize: fontSize.getValue(FontSizeType.rem, 0.83),
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(
          vertical: fontSize.getValue(FontSizeType.rem, 1.67).value,
        ),
      );
    }
    if (node is H6Node) {
      return copyWith(
        fontSize: fontSize.getValue(FontSizeType.rem, 0.67),
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(
          vertical: fontSize.getValue(FontSizeType.rem, 2.33).value,
        ),
      );
    }
    if (node is PNode) {
      return copyWith(
        margin: EdgeInsets.symmetric(
          vertical: fontSize.getValue(FontSizeType.rem, 1.0).value,
        ),
      );
    }
    if (node is ANode) {
      final customTheme = customTagTheme[ANode];
      // print(customTagTheme);

      return copyWith(
        textColor: customTheme?.textColor ?? Colors.blue,
        margin: EdgeInsets.symmetric(horizontal: 1),
        textDecoration: () => TextDecoration.underline,
      );
    }
    if (node is UlNode) {
      return copyWith(
        margin: EdgeInsets.only(left: 40),
        listDecoration: ListDecoration.disc,
      );
    }

    return this;
  }

  void addTheme(Type node, CssTheme cssTheme) {
    customTagTheme[node] = cssTheme;
  }
}

enum FontSizeType {
  px,
  rem,
}

class FontSize {
  final double value;
  final FontSizeType type;

  const FontSize({required this.value, required this.type});

  FontSize getValue(FontSizeType type, double value) {
    return switch (type) {
      FontSizeType.px => FontSize(value: this.value, type: FontSizeType.px),
      FontSizeType.rem =>
        FontSize(value: this.value * value, type: FontSizeType.px),
    };
  }
}
