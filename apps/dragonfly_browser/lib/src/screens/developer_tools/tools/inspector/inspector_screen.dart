import 'package:dragonfly/main.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/dom.dart' show Element;

class InspectorScreen extends StatelessWidget {
  const InspectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HTMLDisplay();
  }
}

class _HTMLDisplay extends StatelessWidget {
  const _HTMLDisplay();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserCubit, Browser>(
      builder: (context, state) {
        final currentPage = state.currentTab?.currentPage;

        if (currentPage == null || currentPage is! HtmlPage) {
          return const SizedBox.shrink();
        }

        final document = currentPage.document;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: document!.children
              .take(1)
              .map(
                (e) => HTMLElementBlock(
                  element: e,
                  indent: 0,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class HTMLElementBlock extends StatefulWidget {
  const HTMLElementBlock({
    super.key,
    required this.element,
    required this.indent,
  });

  final Element element;
  final int indent;

  @override
  State<HTMLElementBlock> createState() => _HTMLElementBlockState();
}

class _HTMLElementBlockState extends State<HTMLElementBlock> {
  bool isHovered = false;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final tagName = widget.element.localName;
    final content = <String>[tagName!];
    final classes = widget.element.className;

    if (classes.isNotEmpty) {
      content.add("class=\"$classes\"");
    }

    for (var at in widget.element.attributes.entries) {
      content.add("${at.key}=\"${at.value}\"");
    }

    final isSelfClosed =
        widget.element.children.isEmpty && widget.element.nodes.isEmpty;

    final openTag =
        (isSelfClosed) ? "<${content.join(" ")} />" : "<${content.join(" ")}>";

    if (isExpanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            htmlHighlighter.highlight(openTag),
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.0 * widget.indent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.element.children
                  .map(
                    (e) => HTMLElementBlock(
                      element: e,
                      indent: widget.indent + 1,
                    ),
                  )
                  .toList(),
            ),
          ),
          Text.rich(
            htmlHighlighter.highlight("</$tagName>"),
          ),
        ],
      );
    }

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHovered = false;
        });
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: (isHovered)
                ? Theme.of(context).colorScheme.primaryContainer
                : null),
        child: Wrap(
          children: [
            Text.rich(
              htmlHighlighter.highlight(openTag),
            ),
            if (widget.element.children.isEmpty &&
                widget.element.nodes.isNotEmpty)
              Text(widget.element.nodes.first.text ?? "")
            else if (widget.element.children.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = true;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "...",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!isSelfClosed)
              Text.rich(
                htmlHighlighter.highlight("</$tagName>"),
              ),
          ],
        ),
      ),
    );
  }
}
