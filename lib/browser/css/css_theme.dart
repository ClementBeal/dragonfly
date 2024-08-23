import 'package:dragonfly/browser/dom/html_node.dart';
import 'package:flutter/material.dart';

enum ListDecoration { disc, number, none }

enum DisplayType { block, flex }

class CssTheme {
  CssTheme({
    required this.fontSize,
    required this.textColor,
    this.backgroundColor,
    required this.fontWeight,
    this.margin,
    this.textDecoration,
    this.listDecoration,
    required this.lineHeight,
    this.justifyContent,
    this.alignItems,
    this.displayType,
    this.textAlign,
    this.isCentered,
    this.maxWidth,
    this.border,
  });

  CssTheme.initial()
      : fontSize = const FontSize(type: FontSizeType.px, value: 16),
        textColor = Colors.black,
        fontWeight = FontWeight.normal,
        margin = EdgeInsets.zero,
        listDecoration = ListDecoration.none,
        lineHeight = 1.0,
        justifyContent = MainAxisAlignment.start,
        alignItems = CrossAxisAlignment.start,
        displayType = DisplayType.block,
        textAlign = TextAlign.start,
        backgroundColor = null,
        textDecoration = null,
        isCentered = null,
        maxWidth = null,
        border = null;

  final FontSize fontSize;
  final Color textColor;
  final Color? backgroundColor;
  final FontWeight fontWeight;
  final EdgeInsets? margin;
  final TextDecoration? textDecoration;
  final ListDecoration? listDecoration;
  final double lineHeight;
  final MainAxisAlignment? justifyContent;
  final CrossAxisAlignment? alignItems;
  final DisplayType? displayType;
  final TextAlign? textAlign;
  final bool? isCentered;
  final double? maxWidth;
  final Border? border;

  CssTheme copyWith({
    FontSize? fontSize,
    Color? textColor,
    Color? Function()? backgroundColor,
    FontWeight? fontWeight,
    EdgeInsets? margin,
    TextDecoration? Function()? textDecoration,
    ListDecoration? listDecoration,
    double? lineHeight,
    MainAxisAlignment? justifyContent,
    CrossAxisAlignment? alignItems,
    DisplayType? displayType,
    TextAlign? textAlign,
    bool? isCentered,
    double? Function()? maxWidth,
    Border? Function()? border,
  }) =>
      CssTheme(
        fontSize: fontSize ?? this.fontSize,
        textColor: textColor ?? this.textColor,
        backgroundColor:
            backgroundColor != null ? backgroundColor() : this.backgroundColor,
        fontWeight: fontWeight ?? this.fontWeight,
        margin: margin ?? this.margin,
        textDecoration:
            textDecoration != null ? textDecoration() : this.textDecoration,
        listDecoration: listDecoration ?? this.listDecoration,
        lineHeight: lineHeight ?? this.lineHeight,
        justifyContent: justifyContent ?? this.justifyContent,
        alignItems: alignItems ?? this.alignItems,
        displayType: displayType ?? this.displayType,
        textAlign: textAlign ?? this.textAlign,
        isCentered: isCentered ?? this.isCentered,
        maxWidth: maxWidth != null ? maxWidth() : this.maxWidth,
        border: border != null ? border() : this.border,
      );

  // CssTheme merge(CssTheme older, CssTheme newer) {
  //   return CssTheme(
  //     customTagTheme: {...older.customTagTheme, ...newer.customTagTheme},
  //     classes: {...older.classes, ...newer.classes},
  //     alignItems: newer.alignItems ?? newer.
  //   );
  // }

  // CssTheme mergeWithClasses(List<String> classes) {
  //   return this.classes[classes.first]!;
  // }

  CssTheme getStyleForNode(DomNode node, List<String> classes) {
    // if (classes.contains("main-nav") ||
    //     classes.contains("container") ||
    //     classes.contains("footer") ||
    //     classes.contains("testimonial") ||
    //     classes.contains("testimonials") ||
    //     classes.contains("header")) {
    //   return mergeWithClasses(classes);
    // }

    // if (node is BodyNode) {
    //   return copyWith(
    //       fontSize: fontSize.getValue(FontSizeType.px, 16),
    //       margin: EdgeInsets.all(8));
    // }
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
      return copyWith(
        // textColor: customTheme?.textColor ?? Colors.blue,
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
