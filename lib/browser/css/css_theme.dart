enum FontSizeType {
  px,
  rem,
  em,
}

class FontSize {
  late final double size;
  late final FontSizeType type;
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

  double getValue(double rootFontSize, double currentFontSize, int pixelRatio) {
    final value = switch (type) {
      FontSizeType.px => size / pixelRatio,
      FontSizeType.rem => rootFontSize * size,
      FontSizeType.em => currentFontSize * size,
    };

    return value;
  }
}
