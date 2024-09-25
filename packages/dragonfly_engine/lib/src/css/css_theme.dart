enum FontSizeType {
  px,
  rem,
  em,
}

/// Helper to compute size of anything for a specific unit
class FontSize {
  late final double size;
  late final FontSizeType type;

  /// The value to convert into actual pixel
  /// It must receive a value like `0.5m` or `40%`
  final String value;

  FontSize({required this.value}) {
    final match = RegExp(
            r"(-?\d*\.?\d+)(px|rem|em|vw|vh|%|in|cm|mm|pt|pc|ex|ch|vmin|vmax)")
        .firstMatch(value);

    if (match == null) {
      throw Exception("No match for the font size -> $value");
    }

    size = double.parse(match.group(1)!);

    switch (match.group(2)) {
      case "px":
        type = FontSizeType.px;
        break;
      case "rem":
        type = FontSizeType.rem;
        break;
      case "em":
        type = FontSizeType.em;
        break;
    }
  }

  /// Compute the size of the specified dimension
  ///
  /// [rootFontSize] is the font size of the root (<html>)
  ///
  /// [currentFontSize] is the font size of the parent
  ///
  /// [pixelRatio] is the pixel ratio of the device. It's important to pass it
  /// because 1 logical pixel is not always equal to 1 physocial pixel
  double getValue(double rootFontSize, double currentFontSize, int pixelRatio) {
    final value = switch (type) {
      FontSizeType.px => size / pixelRatio,
      FontSizeType.rem => rootFontSize * size,
      FontSizeType.em => currentFontSize * size,
    };

    return value;
  }
}
