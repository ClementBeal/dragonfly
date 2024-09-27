import 'package:collection/collection.dart';
import 'package:dragonfly/main.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/pages/file_explorer_page.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

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

class _CSSVisualizer extends StatelessWidget {
  const _CSSVisualizer({required this.stylesheet});

  final CSSStylesheet stylesheet;

  @override
  Widget build(BuildContext context) {
    var highlightedCode = cssHightlighter.highlight(stylesheet.content);

    return SingleChildScrollView(
      child: Text.rich(highlightedCode),
    );
  }
}
