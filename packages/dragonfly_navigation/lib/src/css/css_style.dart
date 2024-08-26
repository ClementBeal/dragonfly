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
