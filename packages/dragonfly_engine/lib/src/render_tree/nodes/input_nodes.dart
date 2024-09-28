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

  /// Is a "password" field
  final bool isPassord;

  RenderTreeInputText({
    this.name,
    this.maxLength,
    this.isReadOnly,
    this.placeholder,
    this.size = 20,
    this.isPassord = false,
    required super.children,
    required super.commonStyle,
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
    required super.commonStyle,
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
    required super.commonStyle,
  });
}

class RenderTreeInputFile extends RenderTreeBox {
  /// The button's text
  final String? value;

  /// Activate or not the button
  final bool? isDisabled;

  RenderTreeInputFile({
    this.value,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}

class RenderTreeInputCheckbox extends RenderTreeBox {
  /// The button's text
  final bool? isChecked;

  /// Activate or not the button
  final bool? isDisabled;

  RenderTreeInputCheckbox({
    this.isChecked,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}

class RenderTreeInputRadio extends RenderTreeBox {
  /// The button's text
  final bool? isChecked;

  /// Activate or not the button
  final bool? isDisabled;

  RenderTreeInputRadio({
    this.isChecked,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}

class RenderTreeInputHidden extends RenderTreeBox {
  /// The button's text
  final String? value;

  /// Activate or not the button
  final bool? isDisabled;

  RenderTreeInputHidden({
    this.value,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}
