import 'package:dragonfly/browser/css/css_theme.dart';
import 'package:dragonfly/browser/css/cssom_builder.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/browser/page.dart';
import 'package:dragonfly/src/screens/browser/browser_theme.dart';
import 'package:dragonfly/src/screens/browser/helpers/color_utils.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:html/dom.dart' hide Text;

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      contextMenuBuilder: (BuildContext context, editableTextState) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: <ContextMenuButtonItem>[
            ...editableTextState.contextMenuButtonItems,
            ContextMenuButtonItem(
              onPressed: () {
                final state = context.read<BrowserCubit>().state;
                final currentTab = state.currentTab;
              },
              label: 'View Source',
            ),
          ],
        );
      },
      child: BlocBuilder<BrowserCubit, Browser>(
        builder: (context, state) {
          final tab = state.currentTab;

          if (tab == null) {
            return const Center(
              child: Text("Enter an URL"),
            );
          }

          if (tab.currentPage == null) {
            return SizedBox.shrink();
          }

          final currentPage = tab.currentPage!;

          return switch (currentPage.status) {
            PageStatus.loading => Center(child: CircularProgressIndicator()),
            PageStatus.error => Center(
                child: Text("Error"),
              ),
            PageStatus.success => SizedBox.expand(
                child: SingleChildScrollView(
                  child: CSSOMProvider(
                    cssom: CSSOM.initial(),
                    child: (currentPage.document!.body != null)
                        ? DomWidget(
                            currentPage.document!.body!,
                          )
                        : SizedBox.shrink(),
                  ),
                ),
              )
          };
        },
      ),
    );
  }
}

class DomWidget extends StatelessWidget {
  const DomWidget(this.domNode, {super.key, this.parentStyle});

  final Element domNode;
  final CssStyle? parentStyle;

  @override
  Widget build(BuildContext context) {
    final tag = domNode.localName;
    final children = domNode.children;
    final style = switch (tag) {
      null => CssStyle.initial(),
      _ =>
        (CSSOMProvider.of(context)!.cssom.find(tag)?.data ?? CssStyle.initial())
    }
        .clone();
    if (parentStyle != null) {
      style.inheritFromParent(parentStyle!);
    }

    // the styles from the classes are not passed to the children
    // final styleWithClasses = style.clone();

    for (var className in domNode.classes) {
      final newTheme =
          CSSOMProvider.of(context)!.cssom.find(".$className")?.data;
      if (newTheme != null) {
        style.mergeClass(newTheme);
      }
    }

    return switch (tag) {
      "img" => Builder(
          builder: (context) {
            final image = Favicon(href: domNode.attributes["src"]!);
            final alt = domNode.attributes["alt"];
            final placeholder = domNode.attributes["placeholder"];

            final currentTab = context.read<BrowserCubit>().state.currentTab;

            return switch (image.type) {
              FaviconType.unknown => DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  child: (alt == null)
                      ? const Icon(
                          Icons.image,
                          size: 22,
                        )
                      : Text(alt),
                ),
              FaviconType.url => Image.network(image.href),
              FaviconType.png ||
              FaviconType.ico ||
              FaviconType.jpeg ||
              FaviconType.webp ||
              FaviconType.gif =>
                (image.isMemoryImage)
                    ? Image.memory(
                        image.decodeBase64()!,
                        semanticLabel: alt,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(placeholder ?? "No picture found");
                        },
                      )
                    : Image.network(Uri.parse(currentTab!.currentPage!.url)
                        .replace(path: image.href)
                        .toString()),
              FaviconType.svg => SvgPicture.memory(
                  image.decodeBase64()!,
                  height: 120,
                  width: 120,
                ),
            };
          },
        ),
      "li" => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Icon(Icons.circle, size: 8),
            // Text("stp")
            ...children.map((e) => DomWidget(e)),
          ],
        ),
      "ol" => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((e) => DomWidget(
                    e,
                    parentStyle: style,
                  ))
              .toList(),
        ),
      "a" => AWidget(domNode: domNode, style: style, children: children),
      _ => BlockNode(
          node: domNode,
          style: style,
          children: children
              .map(
                (e) => DomWidget(
                  e,
                  parentStyle: style,
                ),
              )
              .toList(),
        ),
    };
  }
}

class AWidget extends StatelessWidget {
  const AWidget({
    super.key,
    required this.domNode,
    required this.style,
    required this.children,
  });

  final Element domNode;
  final CssStyle style;
  final List<Element> children;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final href = domNode.attributes["href"]!;

          Uri uri;
          if (href.startsWith('/') ||
              href.startsWith('./') ||
              !href.contains('://')) {
            // Relative link
            uri = Uri.parse(context
                    .read<BrowserCubit>()
                    .state
                    .currentTab!
                    .currentPage!
                    .url)
                .resolve(href);
          } else {
            // Assume absolute URI
            uri = Uri.parse(href);
          }

          context.read<BrowserCubit>().navigateToPage(uri.toString());
        },
        child: BlockNode(
          node: domNode,
          style: style,
          children: children.map((e) => DomWidget(e)).toList(),
        ),
      ),
    );
  }
}

class BlockNode extends StatelessWidget {
  const BlockNode(
      {super.key,
      required this.style,
      required this.node,
      this.children = const []});

  final CssStyle style;
  final Element node;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // TODO : it works on my machine. Probably not on another one
    // the Mediaquery.devicePixelRatio returns 1 for me when it's 3...
    const pixelRatio = 3;
    final display = style.display;
    final fontSize = (style.fontSize != null)
        // TODO : why we can use logical pixel here and not for margin?
        ? FontSize(value: style.fontSize!).getValue(16, 0.0, 1)
        : null;

    final text = node.nodes
        .where((node) => node.nodeType == Node.TEXT_NODE)
        .map((node) => node.text)
        .join();
    final textIsEmpty = text.trim().isEmpty;

    final bloc = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: parseBorderSide(style.borderLeft ?? style.border),
          right: parseBorderSide(style.borderRight ?? style.border),
          top: parseBorderSide(style.borderTop ?? style.border),
          bottom: parseBorderSide(style.borderBottom ?? style.border),
        ),
        borderRadius: (style.borderRadius != null)
            ? BorderRadius.all(
                Radius.circular(
                  FontSize(value: style.borderRadius!)
                      .getValue(16, fontSize ?? 0.0, 1),
                ),
              )
            : null,
        color: (style.backgroundColor != null)
            ? HexColor.fromHex(style.backgroundColor!)
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: (style.paddingBottom != null && style.paddingBottom != "0")
              ? FontSize(value: style.paddingBottom!)
                  .getValue(16, fontSize ?? 0.0, pixelRatio)
              : 0.0,
          left: (style.paddingLeft != null && style.paddingLeft != "0")
              ? FontSize(value: style.paddingLeft!)
                  .getValue(16, fontSize ?? 0.0, pixelRatio)
              : 0.0,
          top: (style.paddingTop != null && style.paddingTop != "0")
              ? FontSize(value: style.paddingTop!)
                  .getValue(16, fontSize ?? 0.0, pixelRatio)
              : 0.0,
          right: (style.paddingRight != null && style.paddingRight != "0")
              ? FontSize(value: style.paddingRight!)
                  .getValue(16, fontSize ?? 0.0, pixelRatio)
              : 0.0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (style.maxWidth != null)
                ? FontSize(value: style.maxWidth!)
                    .getValue(16, fontSize ?? 0.0, 1)
                : double.infinity,
            minHeight: (style.minHeight != null)
                ? FontSize(value: style.minHeight!)
                    .getValue(16, fontSize ?? 0.0, 1)
                : 0.0,
          ),
          child: switch (display) {
            "grid" => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: (style.gap != null)
                    ? FontSize(value: style.gap!).getValue(16, 16, 1)
                    : 0,
                mainAxisSpacing: (style.gap != null)
                    ? FontSize(value: style.gap!).getValue(16, 16, 1)
                    : 0,
                crossAxisCount: 3,
                children: <Widget>[
                  if (!textIsEmpty) TextWidget(text: text, style: style),
                  ...children,
                ],
              ),
            _ => Flex(
                direction: switch (display) {
                  "inline-block" => Axis.horizontal,
                  // "flex" => Axis.horizontal,
                  _ => Axis.vertical,
                },
                crossAxisAlignment: switch (display) {
                  "inline-block" => CrossAxisAlignment.start,
                  _ => CrossAxisAlignment.stretch,
                },
                mainAxisSize: switch (display) {
                  "inline-block" => MainAxisSize.min,
                  _ => MainAxisSize.max,
                },
                mainAxisAlignment: switch (display) {
                  "inline-block" => MainAxisAlignment.start,
                  "flex" => switch (style.justifyContent) {
                      "center" => MainAxisAlignment.center,
                      _ => MainAxisAlignment.start
                    },
                  _ => MainAxisAlignment.start,
                },
                children: [
                  if (!textIsEmpty) TextWidget(text: text, style: style),
                  ...children,
                ],
              ),
          },
        ),
      ),
    );

    if (style.marginBottom != null ||
        style.marginLeft != null ||
        style.marginTop != null ||
        style.marginRight != null) {
      if (style.marginBottom == "auto" &&
          style.marginLeft == "auto" &&
          style.marginTop == "auto" &&
          style.marginRight == "auto") {
        return Align(
          alignment: Alignment.center,
          child: bloc,
        );
      } else {
        return Container(
          margin: EdgeInsets.only(
            bottom: (style.marginBottom != null &&
                    style.marginBottom != "0" &&
                    style.marginBottom != "auto")
                ? FontSize(value: style.marginBottom!)
                    .getValue(16, fontSize ?? 0.0, pixelRatio)
                : 0.0,
            left: (style.marginLeft != null &&
                    style.marginLeft != "0" &&
                    style.marginLeft != "auto")
                ? FontSize(value: style.marginLeft!)
                    .getValue(16, fontSize ?? 0.0, pixelRatio)
                : 0.0,
            top: (style.marginTop != null &&
                    style.marginTop != "0" &&
                    style.marginTop != "auto")
                ? FontSize(value: style.marginTop!)
                    .getValue(16, fontSize ?? 0.0, pixelRatio)
                : 0.0,
            right: (style.marginRight != null &&
                    style.marginRight != "0" &&
                    style.marginRight != "auto")
                ? FontSize(value: style.marginRight!)
                    .getValue(16, fontSize ?? 0.0, pixelRatio)
                : 0.0,
          ),
          child: bloc,
        );
      }
    }

    return bloc;
  }

  BorderSide parseBorderSide(String? borderString) {
    if (borderString == null) return BorderSide.none;

    final parts = borderString.split(' ');

    final width = FontSize(value: parts[0]).getValue(16, 0, 1);
    final style = parts[1];
    final color = HexColor.fromHex(parts[2]);

    BorderStyle borderStyle;
    switch (style) {
      case 'solid':
        borderStyle = BorderStyle.solid;
        break;
      case 'none':
        borderStyle = BorderStyle.none;
        break;
      default:
        throw Exception('Unsupported border style: $style');
    }

    // Return the BorderSide
    return BorderSide(
      width: width,
      style: borderStyle,
      color: color,
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    required this.style,
  });

  final String? text;
  final CssStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: switch (style.textAlign) {
        "left" => TextAlign.left,
        "center" => TextAlign.center,
        _ => TextAlign.left
      },
      style: TextStyle(
        height: style.lineHeight,
        fontSize: (style.fontSize != null)
            // TODO : why we can use logical pixel here and not for margin?
            ? FontSize(value: style.fontSize!).getValue(16, 0.0, 1)
            : null,
        decoration: (style.textDecoration == "underline")
            ? TextDecoration.underline
            : null,
        fontWeight: switch (style.fontWeight) {
          "bold" || "700" => FontWeight.bold,
          "400" => FontWeight.w400,
          _ => null,
        },
        color: (style.textColor != null)
            ? HexColor.fromHex(style.textColor!)
            : null,
      ),
    );
  }
}
