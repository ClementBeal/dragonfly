import 'package:dragonfly/browser/css/css_theme.dart';
import 'package:dragonfly/browser/dom/html_node.dart';
import 'package:dragonfly/browser/dom_builder.dart';
import 'package:dragonfly/main.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/browser/page.dart';
import 'package:dragonfly/src/screens/browser/errors/cant_find_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

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
                    (currentTab!.currentResponse! as Success).sourceCode);
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

                    return DomWidget(m.content);
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
            null => SizedBox.shrink(),
            Empty() => SizedBox.shrink(),
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
    final style = domNode.data.theme;
    final data = domNode.data;
    final children = domNode.children;
    final classes = data.classes;
    // final style = cssTheme.getStyleForNode(data, classes);

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
      UnkownNode() => SizedBox.shrink(),
      HtmlNode() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
              .map((e) => DomWidget(
                    e,
                  ))
              .toList(),
        ),
      HeadNode() => SizedBox.shrink(),
      BodyNode() => DecoratedBox(
          decoration: BoxDecoration(
            color: style.backgroundColor,
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
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
      TitleNode() => SizedBox.shrink(),
      LinkNode() => SizedBox.shrink(),
      DivNode() => Builder(builder: (context) {
          final c = Padding(
            padding: style.margin ?? EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: style.maxWidth ?? double.infinity,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: style.border,
                ),
                child: Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: children
                      .map((e) => DomWidget(
                            e,
                          ))
                      .toList(),
                ),
              ),
            ),
          );

          if (style.isCentered ?? false) {
            return Center(
              child: c,
            );
          }

          return c;
        }),
      NavNode() => DecoratedBox(
          decoration: BoxDecoration(
            color: style.backgroundColor,
          ),
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: style.alignItems ?? CrossAxisAlignment.start,
            mainAxisSize: (style.displayType == DisplayType.flex)
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: style.justifyContent ?? MainAxisAlignment.start,
            children: children
                .map((e) => DomWidget(
                      e,
                    ))
                .toList(),
          ),
        ),
      FooterNode() => DecoratedBox(
          decoration: BoxDecoration(
            color: style.backgroundColor,
          ),
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map((e) => DomWidget(
                      e,
                    ))
                .toList(),
          ),
        ),
      SectionNode() => DecoratedBox(
          decoration: BoxDecoration(
            color: style.backgroundColor,
          ),
          child: Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children
                .map((e) => DomWidget(
                      e,
                    ))
                .toList(),
          ),
        ),
      HeaderNode() => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((e) => DomWidget(
                    e,
                  ))
              .toList(),
        ),
      UlNode() => Padding(
          padding: style.margin ?? EdgeInsets.zero,
          child: Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children
                .map(
                  (e) => DomWidget(e),
                )
                .toList(),
          ),
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
                    if (style.listDecoration == ListDecoration.disc)
                      Text(
                        "\u2022",
                        style: TextStyle(color: style.textColor),
                      ),
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
      H1Node(text: var t) => Padding(
          padding: style.margin ?? EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t,
                style: TextStyle(
                  height: style.lineHeight,
                  color: style.textColor,
                  fontSize: style.fontSize.value,
                  fontWeight: style.fontWeight,
                ),
              ),
              ...children.map((e) => DomWidget(
                    e,
                  )),
            ],
          ),
        ),
      H2Node(text: var t) => Padding(
          padding: style.margin ?? EdgeInsets.zero,
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t,
                style: TextStyle(
                  height: style.lineHeight,
                  color: style.textColor,
                  fontSize: style.fontSize.value,
                  fontWeight: style.fontWeight,
                ),
              ),
              ...children.map((e) => DomWidget(
                    e,
                  )),
            ],
          ),
        ),
      H3Node(text: var t) => Padding(
          padding: style.margin ?? EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t,
                style: TextStyle(
                  height: style.lineHeight,
                  color: style.textColor,
                  fontSize: style.fontSize.value,
                  fontWeight: style.fontWeight,
                ),
              ),
              ...children.map((e) => DomWidget(
                    e,
                  )),
            ],
          ),
        ),
      H4Node(text: var t) => Padding(
          padding: style.margin ?? EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t,
                style: TextStyle(
                  height: style.lineHeight,
                  color: style.textColor,
                  fontSize: style.fontSize.value,
                  fontWeight: style.fontWeight,
                ),
              ),
              ...children.map((e) => DomWidget(
                    e,
                  )),
            ],
          ),
        ),
      H5Node(text: var t) => Padding(
          padding: style.margin ?? EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t,
                style: TextStyle(
                  height: style.lineHeight,
                  color: style.textColor,
                  fontSize: style.fontSize.value,
                  fontWeight: style.fontWeight,
                ),
              ),
              ...children.map((e) => DomWidget(
                    e,
                  )),
            ],
          ),
        ),
      H6Node(text: var t) => Padding(
          padding: style.margin ?? EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t,
                style: TextStyle(
                  height: style.lineHeight,
                  color: style.textColor,
                  fontSize: style.fontSize.value,
                  fontWeight: style.fontWeight,
                ),
              ),
              ...children.map((e) => DomWidget(
                    e,
                  )),
            ],
          ),
        ),
      INode(text: var t) => Text(t),
      BNode(text: var t) => Text(t),
      EmNode(text: var t) => Text(t),
      StrongNode(text: var t) => Text(t),
      PNode(text: var t) => Padding(
          padding: style.margin ?? EdgeInsets.zero,
          child: Text(
            t,
            textAlign: style.textAlign,
            style: TextStyle(
              color: style.textColor,
            ),
          ),
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
  final CssTheme style;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.text,
              style: TextStyle(
                fontSize: style.fontSize.value,
                color: style.textColor,
                decorationColor: style.textColor,
                decoration: style.textDecoration,
              ),
            ),
            ...children.map((e) => DomWidget(e)).toList(),
          ],
        ),
      ),
    );
  }
}
