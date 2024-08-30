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
  List<RenderTreeObject> children;
  String? backgroundColor;
  double? paddingTop;
  double? paddingRight;
  double? paddingBottom;
  double? paddingLeft;
  double? marginTop;
  double? marginRight;
  double? marginBottom;
  double? marginLeft;
  double? borderWidth;

  RenderTreeBox(
      {required this.children,
      this.backgroundColor,
      this.paddingTop,
      this.paddingRight,
      this.paddingBottom,
      this.paddingLeft,
      this.marginTop,
      this.marginRight,
      this.marginBottom,
      this.marginLeft,
      this.borderWidth});

  @override
  String toString() {
    return "RenderTreeBox";
  }
}

class RenderTreeText extends RenderTreeObject {
  String text;
  String? fontFamily;
  double? fontSize;
  String? color;
  String? textDecoration; // "underline", "overline", "line-through"
  double? letterSpacing;
  double? wordSpacing;
  String? textAlign; // "left", "center", "right", "justify"
  String? fontWeight;

  RenderTreeText({
    required this.text,
    this.fontFamily,
    this.fontSize,
    this.color,
    this.textDecoration,
    this.letterSpacing,
    this.wordSpacing,
    this.textAlign,
    this.fontWeight,
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
