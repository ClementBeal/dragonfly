import 'package:dragonfly_engine/src/css/css_style.dart';

part 'input_nodes.dart';

sealed class RenderTreeObject {
  RenderTreeObject({required this.domElementHash});

  final int domElementHash;

  CommonStyle? findStyle(int nodeHash);
}

class CommonStyle {
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
  final bool? isCentered;
  final String? cursor;

  CommonStyle({
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
    required this.borderRadius,
    required this.maxWidth,
    required this.maxHeight,
    required this.minWidth,
    required this.minHeight,
    required this.isCentered,
    required this.cursor,
  });

  factory CommonStyle.fromCSSStyle(CssStyle c) {
    return CommonStyle(
      marginBottom: c.marginBottomConverted,
      marginLeft: c.marginLeftConverted,
      marginTop: c.marginTopConverted,
      marginRight: c.marginRightConverted,
      paddingBottom: c.paddingBottomConverted,
      paddingLeft: c.paddingLeftConverted,
      paddingTop: c.paddingTopConverted,
      paddingRight: c.paddingRightConverted,
      borderBottomColor: c.borderBottomColor,
      borderLeftColor: c.borderLeftColor,
      borderRightColor: c.borderRightColor,
      borderTopColor: c.borderTopColor,
      borderLeftWidth: c.borderLeftWidthConverted,
      borderRightWidth: c.borderRightWidthConverted,
      borderTopWidth: c.borderTopWidthConverted,
      borderBottomWidth: c.borderBottomWidthConverted,
      maxHeight: c.maxHeightConverted,
      maxWidth: c.maxWidthConverted,
      borderRadius: c.borderRadiusConverted,
      minHeight: c.minHeightConverted,
      minWidth: c.minWidthtConverted,
      isCentered: c.isCentered,
      backgroundColor: c.backgroundColor,
      borderWidth: null,
      cursor: c.cursor,
    );
  }

  factory CommonStyle.empty() => CommonStyle(
        backgroundColor: null,
        paddingTop: null,
        paddingRight: null,
        paddingBottom: null,
        paddingLeft: null,
        marginTop: null,
        marginRight: null,
        marginBottom: null,
        marginLeft: null,
        borderWidth: null,
        borderLeftColor: null,
        borderRightColor: null,
        borderTopColor: null,
        borderBottomColor: null,
        borderLeftWidth: null,
        borderRightWidth: null,
        borderTopWidth: null,
        borderBottomWidth: null,
        borderRadius: null,
        maxWidth: null,
        maxHeight: null,
        minWidth: null,
        minHeight: null,
        isCentered: null,
        cursor: null,
      );
}

class RenderTreeView extends RenderTreeObject {
  final double devicePixelRatio;
  final RenderTreeObject child;
  final String backgroundColor;

  RenderTreeView({
    required this.devicePixelRatio,
    required this.child,
    required this.backgroundColor,
    required super.domElementHash,
  });

  @override
  String toString() {
    return "RenderTreeView";
  }

  @override
  CommonStyle? findStyle(int nodeHash) {
    return (nodeHash == domElementHash) ? null : child.findStyle(nodeHash);
  }
}

class RenderTreeBox extends RenderTreeObject {
  final List<RenderTreeObject> children;
  final CommonStyle commonStyle;

  RenderTreeBox({
    required this.children,
    required this.commonStyle,
    required super.domElementHash,
  });

  @override
  String toString() {
    return "RenderTreeBox";
  }

  @override
  CommonStyle? findStyle(int nodeHash) {
    if (nodeHash == domElementHash) return commonStyle;

    for (var child in children) {
      final a = child.findStyle(nodeHash);
      if (a != null) return a;
    }

    return null;
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
    required super.domElementHash,
  });

  @override
  String toString() {
    return "RenderTreeText";
  }

  @override
  CommonStyle? findStyle(int nodeHash) {
    return null;
  }
}

class RenderTreeInline extends RenderTreeObject {
  final List<RenderTreeObject> children;

  RenderTreeInline({
    required this.children,
    required super.domElementHash,
  });

  @override
  CommonStyle? findStyle(int nodeHash) {
    for (var child in children) {
      if (child.domElementHash == nodeHash) return null;
    }
    return null;
  }
}

class RenderTreeList extends RenderTreeBox {
  final String listType;

  RenderTreeList({
    required this.listType,
    required super.commonStyle,
    required super.children,
    required super.domElementHash,
  });
}

class RenderTreeListItem extends RenderTreeBox {
  RenderTreeListItem({
    required super.children,
    required super.commonStyle,
    required super.domElementHash,
  });
}

class RenderTreeLink extends RenderTreeBox {
  final String link;

  RenderTreeLink({
    required this.link,
    required super.commonStyle,
    required super.children,
    required super.domElementHash,
  });
}

class RenderTreeImage extends RenderTreeBox {
  final String link;

  RenderTreeImage({
    required this.link,
    required super.commonStyle,
    required super.children,
    required super.domElementHash,
  });
}

class RenderTreeFlex extends RenderTreeBox {
  final String? direction;
  final String? justifyContent;

  RenderTreeFlex({
    required this.direction,
    required this.justifyContent,
    required super.children,
    required super.commonStyle,
    required super.domElementHash,
  });
}

class RenderTreeGrid extends RenderTreeBox {
  final double? rowGap;
  final double? columnGap;

  RenderTreeGrid({
    required this.rowGap,
    required this.columnGap,
    required super.children,
    required super.commonStyle,
    required super.domElementHash,
  });
}

class RenderTreeForm extends RenderTreeBox {
  /// The destination of the form
  final String? action;

  /// The HTTP request method : GET, POST, DELETE etc
  final String? method;

  RenderTreeForm({
    required this.method,
    required this.action,
    required super.children,
    required super.commonStyle,
    required super.domElementHash,
  });
}

class RenderTreeScript extends RenderTreeObject {
  RenderTreeScript({required super.domElementHash});

  @override
  CommonStyle? findStyle(int nodeHash) {
    return null;
  }
}
