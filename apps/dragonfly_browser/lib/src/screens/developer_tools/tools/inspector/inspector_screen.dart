import 'package:dragonfly/main.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/developer_tools/cubit/devtols_cubit.dart';
import 'package:dragonfly/src/screens/developer_tools/tools/inspector/tools/inspector_layout.dart';
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

        if (document == null) {
          return SizedBox.shrink();
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...document.children.take(1).map(
                    (e) => HTMLElementBlock(
                      element: e,
                      indent: 0,
                    ),
                  ),
              Divider(),
              InspectorDataPanel(),
            ],
          ),
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
  late final List<GlobalKey<_HTMLElementBlockState>> keys;

  @override
  void initState() {
    super.initState();

    keys = widget.element.children
        .map(
          (e) => GlobalKey<_HTMLElementBlockState>(),
        )
        .toList();
  }

  Future<void> _expandAllSubtree() async {
    // TO DO : refactor that...
    // it works and the expand is pretty but it has an hardcoded delay
    // good enough for a start but definitively bad if the page has a tons of children
    setState(() {
      isExpanded = true;
    });

    await Future.delayed(Duration(milliseconds: 40));

    for (var key in keys) {
      key.currentState?._expandAllSubtree();
    }
  }

  Future<void> _collapseAllSubtree() async {
    // TO DO : refactor that...
    // it works and the expand is pretty but it has an hardcoded delay
    // good enough for a start but definitively bad if the page has a tons of children
    setState(() {
      isExpanded = false;
    });

    await Future.delayed(Duration(milliseconds: 40));

    for (var key in keys) {
      key.currentState?._collapseAllSubtree();
    }
  }

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
      return MouseRegion(
        onEnter: (event) {
          setState(() {
            isHovered = true;
          });
          context.read<DevToolsCubit>().selectDomNode(widget.element.hashCode);
        },
        onExit: (event) {
          setState(() {
            isHovered = false;
          });
        },
        child: GestureDetector(
          onSecondaryTapUp: (details) {
            showElementInspectorMenu(context, widget.element, details, this);
          },
          child: Column(
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
                      .asMap()
                      .entries
                      .map(
                        (e) => HTMLElementBlock(
                          element: e.value,
                          indent: widget.indent + 1,
                          key: keys[e.key],
                        ),
                      )
                      .toList(),
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

    return GestureDetector(
      onSecondaryTapUp: (details) {
        showElementInspectorMenu(context, widget.element, details, this);
      },
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            isHovered = true;
          });
          context.read<DevToolsCubit>().selectDomNode(widget.element.hashCode);
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
                        padding: EdgeInsets.symmetric(horizontal: 8),
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
      ),
    );
  }
}

void showElementInspectorMenu(BuildContext context, Element domElement,
    TapUpDetails details, _HTMLElementBlockState blockState) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      details.globalPosition.dx,
      details.globalPosition.dy,
      details.globalPosition.dx,
      details.globalPosition.dy,
    ),
    items: <PopupMenuEntry>[
      PopupMenuItem<String>(
        value: 'edit',
        child: Text('Edit as HTML'),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Text('Delete node'),
        onTap: () {
          context
              .read<BrowserCubit>()
              .state
              .currentTab
              ?.removeElementFromDOM(domElement);
        },
      ),
      PopupMenuItem<String>(
        value: 'duplicate',
        child: Text('Duplicate node'),
        onTap: () {
          context
              .read<BrowserCubit>()
              .state
              .currentTab
              ?.duplicateElementInDOM(domElement);
        },
      ),
      PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'expand_all',
        child: Text('Expand all'),
        onTap: () {
          blockState._expandAllSubtree();
        },
      ),
      PopupMenuItem<String>(
        value: 'collapse_all',
        child: Text('Collapse all'),
        onTap: () {
          blockState._collapseAllSubtree();
        },
      ),
    ],
  );
}

class InspectorDataPanel extends StatefulWidget {
  const InspectorDataPanel({super.key});

  @override
  State<InspectorDataPanel> createState() => _InspectorDataPanelState();
}

class _InspectorDataPanelState extends State<InspectorDataPanel> {
  int selectedInspectorTool = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              AAA(
                label: "Style",
                isActivated: selectedInspectorTool == 0,
                onTap: () {
                  setState(() {
                    selectedInspectorTool = 0;
                  });
                },
              ),
              AAA(
                label: "Layout",
                isActivated: selectedInspectorTool == 1,
                onTap: () {
                  setState(() {
                    selectedInspectorTool = 1;
                  });
                },
              ),
            ],
          ),
        ),
        IndexedStack(
          index: selectedInspectorTool,
          children: [
            SizedBox.shrink(),
            InspectorLayout(),
          ],
        )
      ],
    );
  }
}

class AAA extends StatelessWidget {
  const AAA({
    super.key,
    required this.label,
    required this.isActivated,
    required this.onTap,
  });

  final String label;
  final bool isActivated;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Durations.short2,
        decoration: BoxDecoration(
          border: Border(
            bottom: (isActivated)
                ? BorderSide(color: Colors.blue, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(child: Text(label)),
        ),
      ),
    );
  }
}
