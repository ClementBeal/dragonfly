import 'package:dragonfly_navigation/dragonfly_navigation.dart';
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
    final htmlStyle = cssom.find("html")!.style..convertUnits(16, 16);

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
        link: element.attributes["href"]!,
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
        backgroundColor: c.backgroundColor,
        borderWidth: null,
      );
    } else if (element.localName! == "img") {
      return RenderTreeImage(
        link: Uri.parse(initialRoute)
            .replace(path: element.attributes["src"]!)
            .toString(),
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
        backgroundColor: c.backgroundColor,
        borderWidth: null,
      );
    } else if (displayProperty == "inline") {
      return RenderTreeInline(
        children: element.children.map((e) => _parse(e, c)).toList(),
      );
    } else if (displayProperty == "grid") {
      print(c.rowGap);
      print(c.columnGap);
      print(c.rowGapConverted);
      print(c.columnGapConverted);
      return RenderTreeGrid(
        columnGap: c.columnGapConverted,
        rowGap: c.rowGapConverted,
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
        backgroundColor: c.backgroundColor,
        borderWidth: null,
        maxHeight: c.maxHeightConverted,
        maxWidth: c.maxWidthConverted,
        borderRadius: c.borderRadiusConverted,
        minHeight: c.minHeightConverted,
        minWidth: c.minWidthtConverted,
        children: element.children.map((e) => _parse(e, c)).toList(),
      );
    } else if (displayProperty == "flex") {
      return RenderTreeFlex(
        direction: "row",
        justifyContent: c.justifyContent,
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
        backgroundColor: c.backgroundColor,
        borderWidth: null,
        maxHeight: c.maxHeightConverted,
        maxWidth: c.maxWidthConverted,
        borderRadius: c.borderRadiusConverted,
        minHeight: c.minHeightConverted,
        minWidth: c.minWidthtConverted,
        children: element.children.map((e) => _parse(e, c)).toList(),
      );
    } else if (displayProperty == "list-item") {
      return RenderTreeListItem(
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
        backgroundColor: c.backgroundColor,
        borderWidth: null,
      );
    } else if (displayProperty == "block") {
      if (c.listStyleType != null) {
        return RenderTreeList(
          listType: c.listStyleType!,
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
          backgroundColor: c.backgroundColor,
          borderWidth: null,
        );
      }

      return RenderTreeBox(
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
        maxWidth: c.maxWidthConverted,
        maxHeight: c.maxHeightConverted,
        borderRadius: c.borderRadiusConverted,
        minHeight: c.minHeightConverted,
        minWidth: c.minWidthtConverted,
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
        backgroundColor: c.backgroundColor,
        borderWidth: null,
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
