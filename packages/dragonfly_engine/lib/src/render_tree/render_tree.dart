import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:dragonfly_engine/src/utils/extension.dart';
import 'package:html/dom.dart';

class RenderTree {
  final RenderTreeView child;

  RenderTree({required this.child});

  @override
  String toString() {
    return "RenderTree:\n|$child";
  }
}

double convertCssSizeToPixels({
  required String cssValue,
  required double baseFontSize,
  required double parentFontSize,
}) {
  final RegExp sizePattern = RegExp(r'^(-?\d*\.?\d+)([a-z%]*)$');
  final match = sizePattern.firstMatch(cssValue.trim());

  if (match == null) {
    throw ArgumentError('Invalid CSS size value: $cssValue');
  }

  double value = double.parse(match.group(1)!);
  String unit = match.group(2)!.toLowerCase();

  switch (unit) {
    case 'px':
    case '':
      return value;
    case 'em':
      return value * parentFontSize;
    case 'rem':
      return value * baseFontSize;
    default:
      throw ArgumentError('Unsupported CSS size unit: $unit');
  }
}

class BrowserRenderTree {
  final Document dom;
  final CssomTree cssom;
  final String initialRoute;

  BrowserRenderTree({
    required this.dom,
    required this.cssom,
    required this.initialRoute,
  });

  RenderTree parse() {
    final htmlStyle = (cssom.find("html")?.style ?? CssStyle(fontSize: "16px"))
      ..convertUnits(16, 16);

    return RenderTree(
      child: RenderTreeView(
        devicePixelRatio: 1,
        backgroundColor: htmlStyle.backgroundColor ?? "#ffffff",
        child: _parse(
          dom.querySelector("body")!,
          htmlStyle,
        ),
      ),
    );
  }

  RenderTreeObject _parse(Element element, CssStyle parentStyle) {
    final rule = cssom.find(element.localName!)?.clone();

    final CssStyle c = (rule != null)
        ? (rule.style..inheritFromParent(parentStyle))
        : parentStyle;

    for (var className in element.classes) {
      final classRule = cssom.find(".$className")?.clone();
      if (classRule != null) c.mergeClass(classRule.style);
    }

    c.convertUnits(16, parentStyle.fontSizeConverted!);

    final text = element.nodes
        .where((a) => a.nodeType == Node.TEXT_NODE)
        .map((a) => a.text)
        .join("")
        .trim();

    final displayProperty = c.display ?? "inline";

    if (element.localName! == "a") {
      return RenderTreeLink(
        link: element.attributes["href"] ?? "",
        commonStyle: CommonStyle.fromCSSStyle(c),
        children: [
          if (element.text != "")
            RenderTreeText(
              text: element.text,
              color: c.textColor,
              fontFamily: c.fontFamily,
              fontSize: c.fontSizeConverted,
              textAlign: c.textAlign,
              fontWeight: c.fontWeight,
              textDecoration: null,
              letterSpacing: null,
              wordSpacing: null,
            ),
          ...element.children.map((e) => _parse(e, c)),
        ],
      );
    } else if (element.localName! == "img") {
      return RenderTreeImage(
        link: element.attributes["src"]!,
        commonStyle: CommonStyle.fromCSSStyle(c),
        children: [
          if (element.text != "")
            RenderTreeText(
              text: element.text,
              color: c.textColor,
              fontFamily: c.fontFamily,
              fontSize: c.fontSizeConverted,
              textAlign: c.textAlign,
              fontWeight: c.fontWeight,
              textDecoration: null,
              letterSpacing: null,
              wordSpacing: null,
            ),
          ...element.children.map((e) => _parse(e, c)),
        ],
      );
    } else if (element.localName! == "form") {
      return RenderTreeForm(
        action: element.attributes["action"],
        method: element.attributes["method"],
        commonStyle: CommonStyle.fromCSSStyle(c),
        children: [
          ...element.children.map((e) => _parse(e, c)),
        ],
      );
    } else if (element.localName! == "input") {
      final inputType = element.attributes["type"];

      if (inputType == "text" || inputType == "password") {
        return RenderTreeInputText(
          isPassord: inputType == "password",
          isReadOnly: element.attributes["readonly"]?.apply(bool.parse),
          maxLength: element.attributes["maxlength"]?.apply(int.parse),
          size: element.attributes["size"]?.apply(int.parse) ?? 20,
          name: element.attributes["name"],
          placeholder: element.attributes["placeholder"],
          commonStyle: CommonStyle.fromCSSStyle(c),
          children: [
            if (element.text != "")
              RenderTreeText(
                text: element.text,
                color: c.textColor,
                fontFamily: c.fontFamily,
                fontSize: c.fontSizeConverted,
                textAlign: c.textAlign,
                fontWeight: c.fontWeight,
                textDecoration: null,
                letterSpacing: null,
                wordSpacing: null,
              ),
            ...element.children.map((e) => _parse(e, c)),
          ],
        );
      } else if (element.attributes["type"] == "submit") {
        return RenderTreeInputSubmit(
          isDisabled: element.attributes["disabled"]?.apply(bool.parse),
          value: element.attributes["value"],
          commonStyle: CommonStyle.fromCSSStyle(c),
          children: [
            if (element.text != "")
              RenderTreeText(
                text: element.text,
                color: c.textColor,
                fontFamily: c.fontFamily,
                fontSize: c.fontSizeConverted,
                textAlign: c.textAlign,
                fontWeight: c.fontWeight,
                textDecoration: null,
                letterSpacing: null,
                wordSpacing: null,
              ),
            ...element.children.map((e) => _parse(e, c)),
          ],
        );
      } else if (element.attributes["type"] == "reset") {
        return RenderTreeInputReset(
          isDisabled: element.attributes["disabled"]?.apply(bool.parse),
          value: element.attributes["value"],
          commonStyle: CommonStyle.fromCSSStyle(c),
          children: [
            if (element.text != "")
              RenderTreeText(
                text: element.text,
                color: c.textColor,
                fontFamily: c.fontFamily,
                fontSize: c.fontSizeConverted,
                textAlign: c.textAlign,
                fontWeight: c.fontWeight,
                textDecoration: null,
                letterSpacing: null,
                wordSpacing: null,
              ),
            ...element.children.map((e) => _parse(e, c)),
          ],
        );
      } else if (element.attributes["type"] == "file") {
        return RenderTreeInputFile(
          isDisabled: element.attributes["disabled"]?.apply(bool.parse),
          value: element.attributes["value"],
          commonStyle: CommonStyle.fromCSSStyle(c),
          children: [
            if (element.text != "")
              RenderTreeText(
                text: element.text,
                color: c.textColor,
                fontFamily: c.fontFamily,
                fontSize: c.fontSizeConverted,
                textAlign: c.textAlign,
                fontWeight: c.fontWeight,
                textDecoration: null,
                letterSpacing: null,
                wordSpacing: null,
              ),
            ...element.children.map((e) => _parse(e, c)),
          ],
        );
      } else if (element.attributes["type"] == "checkbox") {
        return RenderTreeInputCheckbox(
          isChecked: element.attributes["checked"] != null,
          isDisabled: element.attributes["disabled"]?.apply(bool.parse),
          commonStyle: CommonStyle.fromCSSStyle(c),
          children: [
            ...element.children.map((e) => _parse(e, c)),
          ],
        );
      }
    } else if (displayProperty == "inline") {
      return RenderTreeInline(
        children: element.children.map((e) => _parse(e, c)).toList(),
      );
    } else if (displayProperty == "grid") {
      return RenderTreeGrid(
        columnGap: c.columnGapConverted,
        rowGap: c.rowGapConverted,
        commonStyle: CommonStyle.fromCSSStyle(c),
        children: element.children.map((e) => _parse(e, c)).toList(),
      );
    } else if (displayProperty == "flex") {
      return RenderTreeFlex(
        direction: "row",
        justifyContent: c.justifyContent,
        commonStyle: CommonStyle.fromCSSStyle(c),
        children: element.children.map((e) => _parse(e, c)).toList(),
      );
    } else if (displayProperty == "list-item") {
      return RenderTreeListItem(
        commonStyle: CommonStyle.fromCSSStyle(c),
        children: [
          if (element.text != "")
            RenderTreeText(
              text: element.text,
              color: c.textColor,
              fontFamily: c.fontFamily,
              fontSize: (c.fontSize == null)
                  ? null
                  : convertCssSizeToPixels(
                      cssValue: c.fontSize!,
                      baseFontSize: 16,
                      parentFontSize: 16,
                    ),
              textAlign: c.textAlign,
              fontWeight: c.fontWeight,
              textDecoration: null,
              letterSpacing: null,
              wordSpacing: null,
            ),
          ...element.children.map((e) => _parse(e, c)),
        ],
      );
    } else if (displayProperty == "block") {
      if (c.listStyleType != null) {
        return RenderTreeList(
          listType: c.listStyleType!,
          commonStyle: CommonStyle.fromCSSStyle(c),
          children: [
            if (text != "")
              RenderTreeText(
                text: text,
                color: c.textColor,
                fontFamily: c.fontFamily,
                fontSize: c.fontSizeConverted,
                textAlign: c.textAlign,
                fontWeight: c.fontWeight,
                textDecoration: null,
                letterSpacing: null,
                wordSpacing: null,
              ),
            ...element.children.map((e) => _parse(e, c)),
          ],
        );
      }

      return RenderTreeBox(
        commonStyle: CommonStyle.fromCSSStyle(c),
        children: [
          if (text != "")
            RenderTreeText(
              text: text,
              color: c.textColor,
              fontFamily: c.fontFamily,
              fontSize: c.fontSizeConverted,
              textAlign: c.textAlign,
              fontWeight: c.fontWeight,
              textDecoration: null,
              letterSpacing: null,
              wordSpacing: null,
            ),
          ...element.children.map((e) => _parse(e, c)),
        ],
      );
    }

    return RenderTreeText(
      text: text,
      fontFamily: null,
      fontSize: null,
      color: null,
      textDecoration: null,
      letterSpacing: null,
      wordSpacing: null,
      textAlign: null,
      fontWeight: null,
    );
  }
}
