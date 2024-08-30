import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:dragonfly_navigation/src/render_tree/nodes/render_tree_node.dart';
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

  BrowserRenderTree({required this.dom, required this.cssom});

  RenderTree parse() {
    return RenderTree(
      child: RenderTreeView(
        devicePixelRatio: 1,
        backgroundColor: cssom.find("html")?.style.backgroundColor ?? "#ffffff",
        child: _parse(
          dom.querySelector("body")!,
        ),
      ),
    );
  }

  RenderTreeObject _parse(Element element) {
    final c = cssom.find(element.localName!);

    // TO DO : fontSize -> is calculated from REM or EM

    final text = element.nodes
        .where((a) => a.nodeType == Node.TEXT_NODE)
        .map((a) => a.text)
        .join("")
        .trim();

    final displayProperty = c?.style.display ?? "inline";

    if (displayProperty == "inline") {
      return RenderTreeInline(
        children: element.children.map((e) => _parse(e)).toList(),
      );
    } else if (displayProperty == "list-item") {
      return RenderTreeListItem(
        marginBottom: (c!.style.marginBottom == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c.style.marginBottom!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        marginLeft: (c.style.marginLeft == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c.style.marginLeft!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        marginTop: (c.style.marginTop == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c.style.marginTop!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        marginRight: (c.style.marginRight == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c.style.marginRight!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        paddingBottom: (c.style.paddingBottom == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c.style.paddingBottom!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        paddingLeft: (c.style.paddingLeft == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c.style.paddingLeft!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        paddingTop: (c.style.paddingTop == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c.style.paddingTop!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        paddingRight: (c.style.paddingRight == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c.style.paddingRight!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        children: [
          if (element.text != "")
            RenderTreeText(
              text: element.text,
              color: c.style.textColor,
              fontFamily: c.style.fontFamily,
              fontSize: (c.style.fontSize == null)
                  ? null
                  : convertCssSizeToPixels(
                      cssValue: c.style.fontSize!,
                      baseFontSize: 16,
                      parentFontSize: 16,
                    ),
              textAlign: c.style.textAlign,
              fontWeight: c.style.fontWeight,
              textDecoration: null,
              letterSpacing: null,
              wordSpacing: null,
            ),
          ...element.children.map((e) => _parse(e)),
        ],
        backgroundColor: null,
        borderWidth: null,
      );
    } else if (displayProperty == "block") {
      if (c?.style.listStyleType != null) {
        return RenderTreeList(
          listType: c!.style.listStyleType!,
          marginBottom: (c.style.marginBottom == null)
              ? null
              : convertCssSizeToPixels(
                  cssValue: c.style.marginBottom!,
                  baseFontSize: 16,
                  parentFontSize: 16,
                ),
          marginLeft: (c.style.marginLeft == null)
              ? null
              : convertCssSizeToPixels(
                  cssValue: c.style.marginLeft!,
                  baseFontSize: 16,
                  parentFontSize: 16,
                ),
          marginTop: (c.style.marginTop == null)
              ? null
              : convertCssSizeToPixels(
                  cssValue: c.style.marginTop!,
                  baseFontSize: 16,
                  parentFontSize: 16,
                ),
          marginRight: (c.style.marginRight == null)
              ? null
              : convertCssSizeToPixels(
                  cssValue: c.style.marginRight!,
                  baseFontSize: 16,
                  parentFontSize: 16,
                ),
          paddingBottom: (c.style.paddingBottom == null)
              ? null
              : convertCssSizeToPixels(
                  cssValue: c.style.paddingBottom!,
                  baseFontSize: 16,
                  parentFontSize: 16,
                ),
          paddingLeft: (c.style.paddingLeft == null)
              ? null
              : convertCssSizeToPixels(
                  cssValue: c.style.paddingLeft!,
                  baseFontSize: 16,
                  parentFontSize: 16,
                ),
          paddingTop: (c.style.paddingTop == null)
              ? null
              : convertCssSizeToPixels(
                  cssValue: c.style.paddingTop!,
                  baseFontSize: 16,
                  parentFontSize: 16,
                ),
          paddingRight: (c.style.paddingRight == null)
              ? null
              : convertCssSizeToPixels(
                  cssValue: c.style.paddingRight!,
                  baseFontSize: 16,
                  parentFontSize: 16,
                ),
          children: [
            if (text != "")
              RenderTreeText(
                text: text,
                color: c.style.textColor,
                fontFamily: c.style.fontFamily,
                fontSize: (c.style.fontSize == null)
                    ? null
                    : convertCssSizeToPixels(
                        cssValue: c.style.fontSize!,
                        baseFontSize: 16,
                        parentFontSize: 16,
                      ),
                textAlign: c.style.textAlign,
                fontWeight: c.style.fontWeight,
                textDecoration: null,
                letterSpacing: null,
                wordSpacing: null,
              ),
            ...element.children.map((e) => _parse(e)),
          ],
          backgroundColor: null,
          borderWidth: null,
        );
      }

      return RenderTreeBox(
        marginBottom: (c?.style.marginBottom == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c!.style.marginBottom!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        marginLeft: (c?.style.marginLeft == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c!.style.marginLeft!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        marginTop: (c?.style.marginTop == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c!.style.marginTop!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        marginRight: (c?.style.marginRight == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c!.style.marginRight!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        paddingBottom: (c?.style.paddingBottom == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c!.style.paddingBottom!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        paddingLeft: (c?.style.paddingLeft == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c!.style.paddingLeft!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        paddingTop: (c?.style.paddingTop == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c!.style.paddingTop!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        paddingRight: (c?.style.paddingRight == null)
            ? null
            : convertCssSizeToPixels(
                cssValue: c!.style.paddingRight!,
                baseFontSize: 16,
                parentFontSize: 16,
              ),
        children: [
          if (text != "")
            RenderTreeText(
              text: text,
              color: c?.style.textColor,
              fontFamily: c?.style.fontFamily,
              fontSize: (c?.style.fontSize == null)
                  ? null
                  : convertCssSizeToPixels(
                      cssValue: c!.style.fontSize!,
                      baseFontSize: 16,
                      parentFontSize: 16,
                    ),
              textAlign: c?.style.textAlign,
              fontWeight: c?.style.fontWeight,
              textDecoration: null,
              letterSpacing: null,
              wordSpacing: null,
            ),
          ...element.children.map((e) => _parse(e)),
        ],
        backgroundColor: null,
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
