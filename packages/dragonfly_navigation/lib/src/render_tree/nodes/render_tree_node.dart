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
  });
}

class RenderTreeListItem extends RenderTreeBox {
  RenderTreeListItem(
      {required super.children,
      required super.backgroundColor,
      required super.paddingTop,
      required super.paddingRight,
      required super.paddingBottom,
      required super.paddingLeft,
      required super.marginTop,
      required super.marginRight,
      required super.marginBottom,
      required super.marginLeft,
      required super.borderWidth});
}
