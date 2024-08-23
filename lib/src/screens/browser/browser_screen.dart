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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            Success m => SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Builder(builder: (context) {
                    if (m.uri.scheme == "view-source") {
                      return Text.rich(htmlHighlighter.highlight(m.sourceCode));
                    }

                    if (m.theme == null) {
                      return CircularProgressIndicator();
                    }

                    return CSSOMProvider(
                      cssom: m.theme!,
                      child: DomWidget(m.content),
                    );
                  }),
                ),
              ),
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
  const DomWidget(this.domNode, {super.key});

  final Tree domNode;

  @override
  Widget build(BuildContext context) {
    final data = domNode.data;
    final children = domNode.children;
    final style = CSSOMProvider.of(context)!
            .cssom
            .find(switch (data) {
              BodyNode() => "body",
              H1Node() => "h1",
              H2Node() => "h2",
              H3Node() => "h3",
              ANode() => "a",
              _ => "body",
            })
            ?.data ??
        CssStyle.initial();

    for (var className in data.classes) {
      final newTheme =
          CSSOMProvider.of(context)!.cssom.find(".$className")?.data;
      print(className);
      print(newTheme);
      if (newTheme != null) {
        style.merge(newTheme);
      }
    }

    // print(CSSOMProvider.of(context)!.cssom.find(HTMLTag.a)?.data);

    return switch (domNode.data) {
      PageNode() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
              .map((e) => DomWidget(
                    e,
                  ))
              .toList(),
        ),
      UnkownNode() => const SizedBox.shrink(),
      HtmlNode() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
              .map((e) => DomWidget(
                    e,
                  ))
              .toList(),
        ),
      HeadNode() => const SizedBox.shrink(),
      BodyNode() => DecoratedBox(
          decoration: BoxDecoration(
            color: (style.backgroundColor != null)
                ? HexColor.fromHex(style.backgroundColor!)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children
                  .map(
                    (e) => DomWidget(
                      e,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      TitleNode() => const SizedBox.shrink(),
      LinkNode() => const SizedBox.shrink(),
      UlNode() => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map(
                (e) => DomWidget(e),
              )
              .toList(),
        ),
      LiNode(text: var t) => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(t),
            ...children.map((e) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // if (style.listDecoration == ListDecoration.disc)
                    //   Text(
                    //     "\u2022",
                    //     style: TextStyle(color: style.textColor),
                    //   ),
                    DomWidget(
                      e,
                    ),
                  ],
                )),
          ],
        ),
      OlNode() => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((e) => DomWidget(
                    e,
                  ))
              .toList(),
        ),
      ANode aNode => AWidget(t: aNode, style: style, children: children),
      INode(text: var t) ||
      BNode(text: var t) ||
      EmNode(text: var t) ||
      StrongNode(text: var t) ||
      H1Node(text: var t) ||
      H2Node(text: var t) ||
      H3Node(text: var t) ||
      H4Node(text: var t) ||
      H5Node(text: var t) ||
      H6Node(text: var t) ||
      PNode(text: var t) =>
        TextNode(
          text: t,
          style: style,
          children: children
              .map(
                (e) => DomWidget(
                  e,
                ),
              )
              .toList(),
        ),
      SectionNode() ||
      DivNode() ||
      HeaderNode() ||
      FooterNode() ||
      NavNode() =>
        TextNode(
          text: null,
          style: style,
          children: children
              .map(
                (e) => DomWidget(
                  e,
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
          child: TextNode(
            text: t.text,
            style: style,
            children: children.map((e) => DomWidget(e)).toList(),
          )),
    );
  }
}

class TextNode extends StatelessWidget {
  const TextNode(
      {super.key, required this.style, this.text, this.children = const []});

  final CssStyle style;
  final String? text;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // padding: EdgeInsets.only(
    //   bottom: (style.marginBottom != null)
    //       ? FontSize(value: style.marginBottom!).getValue(12)
    //       : 0.0,
    //   left: (style.marginLeft != null)
    //       ? FontSize(value: style.marginLeft!).getValue(12)
    //       : 0.0,
    //   top: (style.marginTop != null)
    //       ? FontSize(value: style.marginTop!).getValue(12)
    //       : 0.0,
    //   right: (style.marginRight != null)
    //       ? FontSize(value: style.marginRight!).getValue(12)
    //       : 0.0,
    // ),
    Widget a = DecoratedBox(
      decoration: BoxDecoration(
        color: (style.backgroundColor != null)
            ? HexColor.fromHex(style.backgroundColor!)
            : null,
      ),
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (text != null)
            Text(
              text!,
              style: TextStyle(
                height: style.lineHeight,
                fontSize: (style.fontSize != null)
                    ? FontSize(value: style.fontSize!).getValue(12)
                    : null,
                decoration: (style.textDecoration == "underline")
                    ? TextDecoration.underline
                    : null,
                fontWeight: style.fontWeight == "bold" ? FontWeight.bold : null,
                color: (style.textColor != null)
                    ? HexColor.fromHex(style.textColor!)
                    : null,
              ),
            ),
          ...children,
        ],
      ),
    );

    if (style.marginBottom == "auto" &&
        style.marginLeft == "auto" &&
        style.marginTop == "auto" &&
        style.marginRight == "auto") {
      a = Center(
        child: a,
      );
    }

    if (style.maxWidth != null) {
      print("Sip");
      a = ConstrainedBox(
          constraints: BoxConstraints(
        maxWidth: (style.maxWidth != null)
            ? FontSize(value: style.maxWidth!).getValue(12)
            : double.infinity,
      ));
    }

    return a;
  }
}
