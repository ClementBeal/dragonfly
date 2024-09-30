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
  });

  final Element element;

  @override
  State<HTMLElementBlock> createState() => _HTMLElementBlockState();
}

class _HTMLElementBlockState extends State<HTMLElementBlock> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tagName = widget.element.localName;

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
              htmlHighlighter.highlight("<$tagName>"),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "...",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ...widget.element.children.map(
              (e) => HTMLElementBlock(
                element: e,
              ),
            ),
            Text.rich(
              htmlHighlighter.highlight("</$tagName>"),
            ),
          ],
        ),
      ),
    );
  }
}
