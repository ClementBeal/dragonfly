sealed class RenderTreeObject {}

class RenderTreeView extends RenderTreeObject {
  final double devicePixelRatio;
  final RenderTreeObject child;
  final String backgroundColor;

  RenderTreeView({
    required this.devicePixelRatio,
    required this.child,
    required this.backgroundColor,
  });

  @override
  String toString() {
    return "RenderTreeView";
  }
}

class RenderTreeBox extends RenderTreeObject {
  final List<RenderTreeObject> children;
  final String? backgroundColor;
  final double? paddingTop;
  final double? paddingRight;
  final double? paddingBottom;
  final double? paddingLeft;
  final double? marginTop;
  final double? marginRight;
  final double? marginBottom;
  final double? marginLeft;
  final double? borderWidth;
  final String? borderLeftColor;
  final String? borderRightColor;
  final String? borderTopColor;
  final String? borderBottomColor;
  final double? borderLeftWidth;
  final double? borderRightWidth;
  final double? borderTopWidth;
  final double? borderBottomWidth;
  final double? borderRadius;

  final double? maxWidth;
  final double? maxHeight;
  final double? minWidth;
  final double? minHeight;

  RenderTreeBox({
    required this.children,
    required this.backgroundColor,
    required this.paddingTop,
    required this.paddingRight,
    required this.paddingBottom,
    required this.paddingLeft,
    required this.marginTop,
    required this.marginRight,
    required this.marginBottom,
    required this.marginLeft,
    required this.borderWidth,
    required this.borderLeftColor,
    required this.borderRightColor,
    required this.borderTopColor,
    required this.borderBottomColor,
    required this.borderLeftWidth,
    required this.borderRightWidth,
    required this.borderTopWidth,
    required this.borderBottomWidth,
    required this.maxHeight,
    required this.maxWidth,
    required this.borderRadius,
    required this.minHeight,
    required this.minWidth,
  });

  @override
  String toString() {
    return "RenderTreeBox";
  }
}

class RenderTreeText extends RenderTreeObject {
  final String text;
  final String? fontFamily;
  final double? fontSize;
  final String? color;
  final String? textDecoration; // "underline", "overline", "line-through"
  final double? letterSpacing;
  final double? wordSpacing;
  final String? textAlign; // "left", "center", "right", "justify"
  final String? fontWeight;

  RenderTreeText({
    required this.text,
    required this.fontFamily,
    required this.fontSize,
    required this.color,
    required this.textDecoration,
    required this.letterSpacing,
    required this.wordSpacing,
    required this.textAlign,
    required this.fontWeight,
  });

  @override
  String toString() {
    return "RenderTreeText";
  }
}

class RenderTreeInline extends RenderTreeObject {
  final List<RenderTreeObject> children;

  RenderTreeInline({
    required this.children,
  });
}

class RenderTreeList extends RenderTreeBox {
  final String listType;

  RenderTreeList({
    required this.listType,
    required super.children,
    required super.backgroundColor,
    required super.paddingTop,
    required super.paddingRight,
    required super.paddingBottom,
    required super.paddingLeft,
    required super.marginTop,
    required super.marginRight,
    required super.marginBottom,
    required super.marginLeft,
    required super.borderWidth,
    required super.borderLeftColor,
    required super.borderRightColor,
    required super.borderTopColor,
    required super.borderBottomColor,
    required super.borderLeftWidth,
    required super.borderRightWidth,
    required super.borderTopWidth,
    required super.borderBottomWidth,
    required super.maxHeight,
    required super.maxWidth,
    required super.borderRadius,
    required super.minHeight,
    required super.minWidth,
  });
}

class RenderTreeListItem extends RenderTreeBox {
  RenderTreeListItem({
    required super.children,
    required super.backgroundColor,
    required super.paddingTop,
    required super.paddingRight,
    required super.paddingBottom,
    required super.paddingLeft,
    required super.marginTop,
    required super.marginRight,
    required super.marginBottom,
    required super.marginLeft,
    required super.borderWidth,
    required super.borderLeftColor,
    required super.borderRightColor,
    required super.borderTopColor,
    required super.borderBottomColor,
    required super.borderLeftWidth,
    required super.borderRightWidth,
    required super.borderTopWidth,
    required super.borderBottomWidth,
    required super.maxHeight,
    required super.maxWidth,
    required super.borderRadius,
    required super.minHeight,
    required super.minWidth,
  });
}

class RenderTreeLink extends RenderTreeBox {
  final String link;

  RenderTreeLink({
    required this.link,
    required super.children,
    required super.backgroundColor,
    required super.paddingTop,
    required super.paddingRight,
    required super.paddingBottom,
    required super.paddingLeft,
    required super.marginTop,
    required super.marginRight,
    required super.marginBottom,
    required super.marginLeft,
    required super.borderWidth,
    required super.borderLeftColor,
    required super.borderRightColor,
    required super.borderTopColor,
    required super.borderBottomColor,
    required super.borderLeftWidth,
    required super.borderRightWidth,
    required super.borderTopWidth,
    required super.borderBottomWidth,
    required super.maxHeight,
    required super.maxWidth,
    required super.borderRadius,
    required super.minHeight,
    required super.minWidth,
  });
}

class RenderTreeImage extends RenderTreeBox {
  final String link;

  RenderTreeImage({
    required this.link,
    required super.children,
    required super.backgroundColor,
    required super.paddingTop,
    required super.paddingRight,
    required super.paddingBottom,
    required super.paddingLeft,
    required super.marginTop,
    required super.marginRight,
    required super.marginBottom,
    required super.marginLeft,
    required super.borderWidth,
    required super.borderLeftColor,
    required super.borderRightColor,
    required super.borderTopColor,
    required super.borderBottomColor,
    required super.borderLeftWidth,
    required super.borderRightWidth,
    required super.borderTopWidth,
    required super.borderBottomWidth,
    required super.maxHeight,
    required super.maxWidth,
    required super.borderRadius,
    required super.minHeight,
    required super.minWidth,
  });
}

class RenderTreeFlex extends RenderTreeBox {
  final String? direction;
  final String? justifyContent;

  RenderTreeFlex({
    required this.direction,
    required this.justifyContent,
    required super.children,
    required super.backgroundColor,
    required super.paddingTop,
    required super.paddingRight,
    required super.paddingBottom,
    required super.paddingLeft,
    required super.marginTop,
    required super.marginRight,
    required super.marginBottom,
    required super.marginLeft,
    required super.borderWidth,
    required super.borderLeftColor,
    required super.borderRightColor,
    required super.borderTopColor,
    required super.borderBottomColor,
    required super.borderLeftWidth,
    required super.borderRightWidth,
    required super.borderTopWidth,
    required super.borderBottomWidth,
    required super.maxHeight,
    required super.maxWidth,
    required super.borderRadius,
    required super.minHeight,
    required super.minWidth,
  });
}

class RenderTreeGrid extends RenderTreeBox {
  final double? rowGap;
  final double? columnGap;

  RenderTreeGrid({
    required this.rowGap,
    required this.columnGap,
    required super.children,
    required super.backgroundColor,
    required super.paddingTop,
    required super.paddingRight,
    required super.paddingBottom,
    required super.paddingLeft,
    required super.marginTop,
    required super.marginRight,
    required super.marginBottom,
    required super.marginLeft,
    required super.borderWidth,
    required super.borderLeftColor,
    required super.borderRightColor,
    required super.borderTopColor,
    required super.borderBottomColor,
    required super.borderLeftWidth,
    required super.borderRightWidth,
    required super.borderTopWidth,
    required super.borderBottomWidth,
    required super.maxHeight,
    required super.maxWidth,
    required super.borderRadius,
    required super.minHeight,
    required super.minWidth,
  });
}
