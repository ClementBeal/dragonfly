import 'package:collection/collection.dart';
import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';
import 'package:dragonfly/main.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StylesheetsScreen extends StatefulWidget {
  const StylesheetsScreen({super.key});

  @override
  State<StylesheetsScreen> createState() => _StylesheetsScreenState();
}

class _StylesheetsScreenState extends State<StylesheetsScreen> {
  CSSStylesheet? selectedStylesheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<BrowserCubit, Browser>(
          builder: (context, state) {
            final currentTab = state.currentTab;
            final currentPage = currentTab?.currentPage;

            if (currentTab == null ||
                currentPage == null ||
                currentPage is! HtmlPage) {
              return const SizedBox();
            }

            final stylesheets = currentPage.stylesheets
                .whereNot(
                  (e) => e.isBrowserStyle,
                )
                .toList();

            return ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) => InkWell(
                onTap: () =>
                    setState(() => selectedStylesheet = stylesheets[index]),
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye_sharp),
                    Text(stylesheets[index].name),
                  ],
                ),
              ),
              separatorBuilder: (context, index) => Divider(),
              itemCount: stylesheets.length,
            );
          },
        ),
        if (selectedStylesheet != null) ...[
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: _CSSVisualizer(stylesheet: selectedStylesheet!),
            ),
          ),
        ],
      ],
    );
  }
}

class _CSSVisualizer extends StatefulWidget {
  const _CSSVisualizer({required this.stylesheet});

  final CSSStylesheet stylesheet;

  @override
  State<_CSSVisualizer> createState() => _CSSVisualizerState();
}

class _CSSVisualizerState extends State<_CSSVisualizer> {
  late final String formattedCode;

  @override
  void initState() {
    super.initState();

    formattedCode = (CssPrinter()
          ..visitTree(parse(widget.stylesheet.content), pretty: true))
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    var highlightedCode = cssHightlighter.highlight(formattedCode);
    final lines = formattedCode.codeUnits.fold(
      1,
      (ini, element) => ini + ((element == "\n".codeUnitAt(0)) ? 1 : 0),
    );

    // TO DO : I really think it's bad to nest 2 SingleChildScrollView
    // not important yet but It has to be changed
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: lines,
                shrinkWrap: true,
                itemBuilder: (context, index) => Text("${index + 1}"),
              ),
            ),
            SelectableText.rich(highlightedCode),
          ],
        ),
      ),
    );
  }
}
