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
  final String? value;
  final bool? isDisabled;

  RenderTreeInputSubmit({
    this.value,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}

class RenderTreeInputReset extends RenderTreeBox {
  final String? value;
  final bool? isDisabled;

  RenderTreeInputReset({
    this.value,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}

class RenderTreeInputFile extends RenderTreeBox {
  final String? name;
  final String? value;
  final bool? isDisabled;

  RenderTreeInputFile({
    this.name,
    this.value,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}

class RenderTreeInputCheckbox extends RenderTreeBox {
  final String? name;
  final bool? isChecked;
  final bool? isDisabled;

  RenderTreeInputCheckbox({
    this.name,
    this.isChecked,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}

class RenderTreeInputRadio extends RenderTreeBox {
  final String? name;
  final bool? isChecked;
  final bool? isDisabled;

  RenderTreeInputRadio({
    this.name,
    this.isChecked,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}

class RenderTreeInputHidden extends RenderTreeBox {
  final String? name; // Added name field
  final String? value;
  final bool? isDisabled;

  RenderTreeInputHidden({
    this.name, // Added name parameter
    this.value,
    this.isDisabled,
    required super.children,
    required super.commonStyle,
  });
}

class RenderTreeInputTextArea extends RenderTreeBox {
  /// The button's text
  final String? value;

  final String? name;

  /// Activate or not the button
  final bool? isDisabled;

  final String? placeholder;
  final int? maxLength;
  final int numberOfRows;
  final int numberOfCols;
  final bool? isReadOnly;

  RenderTreeInputTextArea({
    this.value,
    this.isDisabled,
    this.name,
    this.placeholder,
    this.maxLength,
    required this.numberOfRows,
    required this.numberOfCols,
    this.isReadOnly,
    required super.children,
    required super.commonStyle,
  });
}
