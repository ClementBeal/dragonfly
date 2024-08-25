import 'dart:ui';

import 'package:dragonfly/browser/css/css_theme.dart';
import 'package:dragonfly/browser/css/cssom_builder.dart';
import 'package:dragonfly/browser/dom/html_node.dart';
import 'package:dragonfly/browser/dom_builder.dart';
import 'package:dragonfly/main.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/browser/page.dart';
import 'package:dragonfly/src/screens/browser/browser_theme.dart';
import 'package:dragonfly/src/screens/browser/errors/cant_find_page.dart';
import 'package:dragonfly/src/screens/browser/helpers/color_utils.dart';
import 'package:dragonfly/src/screens/browser/pages/file_special_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

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

                // TODO : it will break
                context.read<BrowserCubit>().addTabAndViewSourceCode(
                    Uri.parse(
                        "view-source:${currentTab!.currentResponse!.uri.toString()}"),
                    (currentTab.currentResponse! as Success).sourceCode);
              },
              label: 'View Source',
            ),
          ],
        );
      },
      child: BlocBuilder<BrowserCubit, BrowserState>(
        builder: (context, state) {
          final tab = state.currentTab;
          final currentTabId = state.currentTabId;

          if (tab == null) {
            return const Center(
              child: Text("Enter an URL"),
            );
          }

          return switch (tab.currentResponse) {
            FileSuccess m => FileSpecialPage(uri: m.uri),
            Success m => Builder(builder: (context) {
                if (m.uri.scheme == "view-source") {
                  return SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text.rich(htmlHighlighter.highlight(m.sourceCode)),
                    ],
                  ));
                }

                if (m.theme == null) {
                  return const CircularProgressIndicator();
                }

                return SizedBox.expand(
                  child: SingleChildScrollView(
                    child: CSSOMProvider(
                      cssom: m.theme!,
                      child: DomWidget(m.content),
                    ),
                  ),
                );
              }),
            Loading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ErrorResponse m => switch (m.error) {
                NavigationError.cantFindPage =>
                  ServerNotFoundPage(tab: m, tabId: currentTabId),
              },
            null => const SizedBox.shrink(),
            Empty() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class DomWidget extends StatelessWidget {
  const DomWidget(this.domNode, {super.key, this.parentStyle});

  final Tree domNode;
  final CssStyle? parentStyle;

  @override
  Widget build(BuildContext context) {
    final data = domNode.data;
    final children = domNode.children;
    final style = (CSSOMProvider.of(context)!
                .cssom
                .find(switch (data) {
                  UlNode() => "ul",
                  BodyNode() => "body",
                  DivNode() => "div",
                  H1Node() => "h1",
                  H2Node() => "h2",
                  H3Node() => "h3",
                  ANode() => "a",
                  PNode() => "p",
                  BlockQuoteNode() => "blockquote",
                  _ => "body",
                })
                ?.data ??
            CssStyle.initial())
        .clone();

    if (parentStyle != null) {
      style.inheritFromParent(parentStyle!);
    }

    // the styles from the classes are not passed to the children
    // final styleWithClasses = style.clone();

    for (var className in data.classes) {
      final newTheme =
          CSSOMProvider.of(context)!.cssom.find(".$className")?.data;
      if (newTheme != null) {
        style.mergeClass(newTheme);
      }
    }

    return switch (domNode.data) {
      UnkownNode() => const SizedBox.shrink(),
      HeadNode() => const SizedBox.shrink(),
      TitleNode() => const SizedBox.shrink(),
      LinkNode() => const SizedBox.shrink(),
      ImgNode() => Builder(
          builder: (context) {
            final image = Favicon(href: data.attributes["src"]!);
            final alt = data.attributes["alt"];
            final placeholder = data.attributes["placeholder"];

            print(image.type);
            final currentTab = context.read<BrowserCubit>().state.currentTab;

            return switch (image.type) {
              FaviconType.unknown => DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  child: (alt == null)
                      ? Icon(
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
                    : Image.network(currentTab!.currentResponse!.uri
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
      LiNode(text: var t) => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Icon(Icons.circle, size: 8),
            // Text("stp")
            ...children.map((e) => DomWidget(e)),
          ],
        ),
      OlNode() => Flex(
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
      ANode aNode => AWidget(t: aNode, style: style, children: children),
      INode(text: var t) ||
      BNode(text: var t) ||
      EmNode(text: var t) ||
      StrongNode(text: var t) ||
      BlockQuoteNode(text: var t) ||
      H1Node(text: var t) ||
      H2Node(text: var t) ||
      H3Node(text: var t) ||
      H4Node(text: var t) ||
      H5Node(text: var t) ||
      H6Node(text: var t) ||
      PNode(text: var t) =>
        BlockNode(
          text: t,
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
      SectionNode() ||
      DivNode() ||
      HeaderNode() ||
      PageNode() ||
      UlNode() ||
      FooterNode() ||
      HtmlNode() ||
      BodyNode() ||
      MainNode() ||
      PreNode() ||
      NavNode() =>
        BlockNode(
          text: null,
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
    required this.t,
    required this.style,
    required this.children,
  });

  final ANode t;
  final CssStyle style;
  final List<Tree> children;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final href = t.attributes["href"]!;

          Uri uri;
          if (href.startsWith('/') ||
              href.startsWith('./') ||
              !href.contains('://')) {
            // Relative link
            uri = Uri.parse(context
                    .read<BrowserCubit>()
                    .state
                    .currentTab!
                    .history
                    .last
                    .uri
                    .toString())
                .resolve(href);
          } else {
            // Assume absolute URI
            uri = Uri.parse(href);
          }

          context.read<BrowserCubit>().visitUri(uri);
        },
        child: BlockNode(
          text: t.text,
          style: style,
          children: children.map((e) => DomWidget(e)).toList(),
        ),
      ),
    );
  }
}

class BlockNode extends StatelessWidget {
  const BlockNode(
      {super.key, required this.style, this.text, this.children = const []});

  final CssStyle style;
  final String? text;
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

    // if (style.backgroundColor != null || style.borderLeft!=null)
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
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: (style.gap != null)
                    ? FontSize(value: style.gap!).getValue(16, 16, 1)
                    : 0,
                mainAxisSpacing: (style.gap != null)
                    ? FontSize(value: style.gap!).getValue(16, 16, 1)
                    : 0,
                crossAxisCount: 3,
                children: <Widget>[
                  if (text != null) TextWidget(text: text, style: style),
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
                  if (text != null) TextWidget(text: text, style: style),
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
