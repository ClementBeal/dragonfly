import 'package:dragonfly_engine/src/render_tree/render_tree.dart';

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
    this.borderLeftColor,
    this.borderRightColor,
    this.borderTopColor,
    this.borderBottomColor,
    this.rowGap,
    this.columnGap,
    this.border,
    this.justifyContent,
    this.alignItems,
    this.minHeight,
    this.fontFamily,
    this.borderLeftWidth,
    this.borderRightWidth,
    this.borderTopWidth,
    this.borderBottomWidth,
    this.cursor,
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

  String? borderLeftWidth;
  String? borderRightWidth;
  String? borderTopWidth;
  String? borderBottomWidth;

  String? borderLeftColor;
  String? borderRightColor;
  String? borderTopColor;
  String? borderBottomColor;

  String? border;
  String? justifyContent;
  String? alignItems;
  String? minHeight;
  String? minWidth;
  String? fontFamily;

  // grid
  String? rowGap;
  String? columnGap;

  String? cursor;

  double? rowGapConverted;
  double? columnGapConverted;

  double? marginTopConverted;
  double? marginBottomConverted;
  double? marginLeftConverted;
  double? marginRightConverted;
  double? paddingTopConverted;
  double? paddingBottomConverted;
  double? paddingLeftConverted;
  double? paddingRightConverted;
  double? fontSizeConverted;

  double? borderLeftWidthConverted;
  double? borderRightWidthConverted;
  double? borderTopWidthConverted;
  double? borderBottomWidthConverted;
  double? borderRadiusConverted;

  double? maxWidthConverted;
  double? maxHeightConverted;
  double? minHeightConverted;
  double? minWidthtConverted;

  void convertUnits(double baseFontSize, double parentFontSize) {
    marginTopConverted = (marginTop != null)
        ? convertCssSizeToPixels(
            cssValue: marginTop!, baseFontSize: 16, parentFontSize: 16)
        : null;
    marginBottomConverted = (marginBottom != null)
        ? convertCssSizeToPixels(
            cssValue: marginBottom!, baseFontSize: 16, parentFontSize: 16)
        : null;
    marginLeftConverted = (marginLeft != null)
        ? convertCssSizeToPixels(
            cssValue: marginLeft!, baseFontSize: 16, parentFontSize: 16)
        : null;
    marginRightConverted = (marginRight != null)
        ? convertCssSizeToPixels(
            cssValue: marginRight!, baseFontSize: 16, parentFontSize: 16)
        : null;
    paddingTopConverted = (paddingTop != null)
        ? convertCssSizeToPixels(
            cssValue: paddingTop!, baseFontSize: 16, parentFontSize: 16)
        : null;
    paddingBottomConverted = (paddingBottom != null)
        ? convertCssSizeToPixels(
            cssValue: paddingBottom!, baseFontSize: 16, parentFontSize: 16)
        : null;
    paddingLeftConverted = (paddingLeft != null)
        ? convertCssSizeToPixels(
            cssValue: paddingLeft!, baseFontSize: 16, parentFontSize: 16)
        : null;
    paddingRightConverted = (paddingRight != null)
        ? convertCssSizeToPixels(
            cssValue: paddingRight!, baseFontSize: 16, parentFontSize: 16)
        : null;

    fontSizeConverted = (fontSize != null)
        ? convertCssSizeToPixels(
            cssValue: fontSize!, baseFontSize: 16, parentFontSize: 16)
        : null;

    borderLeftWidthConverted = (borderLeftWidth != null)
        ? convertCssSizeToPixels(
            cssValue: borderLeftWidth!, baseFontSize: 16, parentFontSize: 16)
        : null;
    borderRightWidthConverted = (borderRightWidth != null)
        ? convertCssSizeToPixels(
            cssValue: borderRightWidth!, baseFontSize: 16, parentFontSize: 16)
        : null;
    borderTopWidthConverted = (borderTopWidth != null)
        ? convertCssSizeToPixels(
            cssValue: borderTopWidth!, baseFontSize: 16, parentFontSize: 16)
        : null;
    borderBottomWidthConverted = (borderBottomWidth != null)
        ? convertCssSizeToPixels(
            cssValue: borderBottomWidth!, baseFontSize: 16, parentFontSize: 16)
        : null;

    maxWidthConverted = (maxWidth != null)
        ? convertCssSizeToPixels(
            cssValue: maxWidth!, baseFontSize: 16, parentFontSize: 16)
        : null;
    maxHeightConverted = (maxHeight != null)
        ? convertCssSizeToPixels(
            cssValue: maxHeight!, baseFontSize: 16, parentFontSize: 16)
        : null;

    minWidthtConverted = (minWidth != null)
        ? convertCssSizeToPixels(
            cssValue: minWidth!, baseFontSize: 16, parentFontSize: 16)
        : null;
    minHeightConverted = (minHeight != null)
        ? convertCssSizeToPixels(
            cssValue: minHeight!, baseFontSize: 16, parentFontSize: 16)
        : null;

    borderRadiusConverted = (borderRadius != null)
        ? convertCssSizeToPixels(
            cssValue: borderRadius!, baseFontSize: 16, parentFontSize: 16)
        : null;

    rowGapConverted = (rowGap != null)
        ? convertCssSizeToPixels(
            cssValue: rowGap!, baseFontSize: 16, parentFontSize: 16)
        : null;
    columnGapConverted = (columnGap != null)
        ? convertCssSizeToPixels(
            cssValue: columnGap!, baseFontSize: 16, parentFontSize: 16)
        : null;
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

    borderLeftColor = newTheme.borderLeftColor ?? borderLeftColor;
    borderRightColor = newTheme.borderRightColor ?? borderRightColor;
    borderTopColor = newTheme.borderTopColor ?? borderTopColor;
    borderBottomColor = newTheme.borderBottomColor ?? borderBottomColor;

    borderLeftWidth = newTheme.borderLeftWidth ?? borderLeftWidth;
    borderRightWidth = newTheme.borderRightWidth ?? borderRightWidth;
    borderTopWidth = newTheme.borderTopWidth ?? borderTopWidth;
    borderBottomWidth = newTheme.borderBottomWidth ?? borderBottomWidth;

    border = newTheme.border ?? border;

    rowGap = newTheme.rowGap ?? rowGap;
    columnGap = newTheme.columnGap ?? columnGap;
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
      borderLeftColor: borderLeftColor,
      borderRightColor: borderRightColor,
      borderTopColor: borderTopColor,
      borderBottomColor: borderBottomColor,
      borderLeftWidth: borderLeftWidth,
      borderRightWidth: borderRightWidth,
      borderTopWidth: borderTopWidth,
      borderBottomWidth: borderBottomWidth,
      rowGap: rowGap,
      columnGap: columnGap,
      border: border,
      justifyContent: justifyContent,
      alignItems: alignItems,
      minHeight: minHeight,
      fontFamily: fontFamily,
      cursor: cursor,
    );
  }
}
