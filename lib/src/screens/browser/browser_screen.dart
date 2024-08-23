import 'package:dragonfly/browser/css/css_theme.dart';
import 'package:dragonfly/browser/dom/html_node.dart';
import 'package:dragonfly/browser/dom_builder.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/browser/page.dart';
import 'package:dragonfly/src/screens/browser/errors/cant_find_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: BlocBuilder<BrowserCubit, BrowserState>(
        builder: (context, state) {
          final tab = state.currentTab;
          final currentTabId = state.currentTabId;

          if (tab == null) {
            return const Center(
              child: Text("Enter an URL"),
            );
          }

          print("Tab -> ${tab}");
          print("Tab css -> ${tab.cssTheme}");

          return switch (tab.currentResponse) {
            Success m => SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: DomWidget(m.content, parentStyle: tab.cssTheme),
                ),
              ),
            Loading() => Center(
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
  const DomWidget(this.domNode, {super.key, this.parentStyle});

  final Tree domNode;
  final CssTheme? parentStyle;

  @override
  Widget build(BuildContext context) {
    final cssTheme = parentStyle ?? CssTheme(customTagTheme: {});
    final data = domNode.data;
    final children = domNode.children;
    final style = cssTheme.getStyleForNode(data);

    return switch (domNode.data) {
      PageNode() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
              .map((e) => DomWidget(
                    e,
                    parentStyle: cssTheme,
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
                    parentStyle: cssTheme,
                  ))
              .toList(),
        ),
      HeadNode() => SizedBox.shrink(),
      BodyNode() => DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
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
                      parentStyle: cssTheme,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      TitleNode() => SizedBox.shrink(),
      LinkNode() => SizedBox.shrink(),
      DivNode() => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((e) => DomWidget(
                    e,
                    parentStyle: cssTheme,
                  ))
              .toList(),
        ),
      NavNode() => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((e) => DomWidget(
                    e,
                    parentStyle: cssTheme,
                  ))
              .toList(),
        ),
      FooterNode() => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((e) => DomWidget(
                    e,
                    parentStyle: cssTheme,
                  ))
              .toList(),
        ),
      SectionNode() => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((e) => DomWidget(
                    e,
                    parentStyle: cssTheme,
                  ))
              .toList(),
        ),
      HeaderNode() => Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children
              .map((e) => DomWidget(
                    e,
                    parentStyle: cssTheme,
                  ))
              .toList(),
        ),
      UlNode() => Padding(
          padding: style.margin,
          child: Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children
                .map(
                  (e) => DomWidget(
                    e,
                    parentStyle: style,
                  ),
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
                      parentStyle: cssTheme,
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
                    parentStyle: cssTheme,
                  ))
              .toList(),
        ),
      ANode aNode => AWidget(t: aNode, style: style, children: children),
      H1Node(text: var t) => Padding(
          padding: style.margin,
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
                    parentStyle: cssTheme,
                  )),
            ],
          ),
        ),
      H2Node(text: var t) => Padding(
          padding: style.margin,
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
                    parentStyle: cssTheme,
                  )),
            ],
          ),
        ),
      H3Node(text: var t) => Padding(
          padding: style.margin,
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
                    parentStyle: cssTheme,
                  )),
            ],
          ),
        ),
      H4Node(text: var t) => Padding(
          padding: style.margin,
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
                    parentStyle: cssTheme,
                  )),
            ],
          ),
        ),
      H5Node(text: var t) => Padding(
          padding: style.margin,
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
                    parentStyle: cssTheme,
                  )),
            ],
          ),
        ),
      H6Node(text: var t) => Padding(
          padding: style.margin,
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
                    parentStyle: cssTheme,
                  )),
            ],
          ),
        ),
      INode(text: var t) => Text(t),
      BNode(text: var t) => Text(t),
      EmNode(text: var t) => Text(t),
      StrongNode(text: var t) => Text(t),
      PNode(text: var t) => Padding(
          padding: style.margin,
          child: Text(t),
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
            ...children
                .map((e) => DomWidget(
                      e,
                      parentStyle: style,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
