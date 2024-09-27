part of 'render_tree_node.dart';

class RenderTreeInputText extends RenderTreeBox {
  /// <input name="..." />
  final String? name;

  /// Limit the number of characters of the input
  final int? maxLength;

  final bool? isReadOnly;

  /// The text to display when the field is empty
  final String? placeholder;

  /// The number of characters to display
  final int size;

  RenderTreeInputText({
    this.name,
    this.maxLength,
    this.isReadOnly,
    this.placeholder,
    this.size = 20,
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
    required super.isCentered,
  });
}

class RenderTreeInputSubmit extends RenderTreeBox {
  /// The button's text
  final String? value;

  /// Activate or not the button
  final bool? isDisabled;

  RenderTreeInputSubmit({
    this.value,
    this.isDisabled,
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
    required super.isCentered,
  });
}

class RenderTreeInputReset extends RenderTreeBox {
  /// The button's text
  final String? value;

  /// Activate or not the button
  final bool? isDisabled;

  RenderTreeInputReset({
    this.value,
    this.isDisabled,
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
    required super.isCentered,
  });
}
