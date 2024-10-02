import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/blocs/render_screen_cubit.dart';
import 'package:dragonfly/src/screens/browser/helpers/color_utils.dart';
import 'package:dragonfly/src/screens/browser/pages/file_explorer_page.dart';
import 'package:dragonfly/src/screens/browser/pages/json/json_screen.dart';
import 'package:dragonfly/src/screens/browser/pages/media_page/media_page_screen.dart';
import 'package:dragonfly/src/screens/browser/render_node_widget/render_image.dart';
import 'package:dragonfly/src/screens/browser/render_node_widget/render_input_text.dart';
import 'package:dragonfly/src/screens/developer_tools/cubit/devtols_cubit.dart';
import 'package:dragonfly/src/screens/lobby/lobby_screen.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart' hide Element, Page, Tab;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:desktop_drop/desktop_drop.dart';

class BrowserScreen extends StatelessWidget {
  const BrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) {
        if (details.files.isNotEmpty) {
          for (var (i, file) in details.files.indexed) {
            final path = Uri.parse("file://${file.path}");

            context.read<BrowserCubit>().openNewTab(
                  initialUri: path,
                  switchTab: i == 0,
                );
          }
        }
      },
      child: SelectionArea(
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

            final currentPage = tab?.currentPage;

            return RenderPageWidget(
              page: currentPage,
            );
          },
        ),
      ),
    );
  }
}

class RenderPageWidget extends StatelessWidget {
  const RenderPageWidget({super.key, required this.page, this.tab});

  final Page? page;
  final Tab? tab;

  @override
  Widget build(BuildContext context) {
    if (page == null) return const LobbyScreen();

    return switch (page!.status) {
      PageStatus.loading => const Center(child: CircularProgressIndicator()),
      PageStatus.error => const Center(
          child: Text("Error"),
        ),
      PageStatus.success => SizedBox.expand(
          child: switch (page!) {
            FileExplorerPage p => FileExplorerPageScreen(
                page: p,
                tab: tab,
              ),
            HtmlPage page => (page.document!.documentElement != null)
                ? BlocBuilder<RenderScreenCubit, RenderScreenState>(
                    builder: (context, state) {
                    // TO DO
                    // dirty hack for testing purpose
                    // it has to be moded to a special package
                    // called `dragonfly_renderer`

                    final renderTree = BrowserRenderTree(
                      dom: page.document!,
                      cssom: CssomBuilder().parse(
                        page.stylesheets
                            .whereType<CSSStylesheet>()
                            .map((e) => e.content)
                            .join("\n"),
                      ),
                      initialRoute: page.uri.toString(),
                    ).parse();

                    return Stack(
                      children: [
                        TreeRenderer(renderTree.child),
                        if (state.hoveredLink != null)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black87,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  state.hoveredLink!,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  })
                : const SizedBox.shrink(),
            MediaPage p => MediaPageScreen(page: p),
            JsonPage p => JsonScreen(page: p),
          },
        ),
    };
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class TreeRenderer extends StatelessWidget {
  const TreeRenderer(this.renderNode, {super.key});

  final RenderTreeObject renderNode;

  @override
  Widget build(BuildContext context) {
    return switch (renderNode) {
      RenderTreeList r => CommonStyleBlock(
          r.commonStyle,
          domHash: r.domElementHash,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in r.children)
                Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                    TreeRenderer(c),
                  ],
                ),
            ],
          ),
        ),
      RenderTreeForm r => BrowserForm(
          r: r,
          child: CommonStyleBlock(
            r.commonStyle,
            domHash: r.domElementHash,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in r.children) TreeRenderer(c),
              ],
            ),
          ),
        ),
      RenderTreeListItem r => CommonStyleBlock(
          r.commonStyle,
          domHash: r.domElementHash,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in r.children) TreeRenderer(c),
            ],
          ),
        ),
      RenderTreeInline r => Row(
          mainAxisSize: MainAxisSize.min,
          children: r.children.map((a) => TreeRenderer(a)).toList(),
        ),
      RenderTreeImage r => Align(
          alignment: Alignment.topLeft,
          child: RenderImage(
            node: r,
          ),
        ),
      RenderTreeView r => DecoratedBox(
          decoration: BoxDecoration(
            color: HexColor.fromHex(r.backgroundColor),
          ),
          child: SizedBox.expand(
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TreeRenderer(r.child),
                  ],
                ),
              ),
            ),
          ),
        ),
      RenderTreeText r => CommonStyleBlock(
          null,
          domHash: r.domElementHash,
          child: Text(
            r.text,
            textAlign: switch (r.textAlign) {
              "start" => TextAlign.start,
              "end" => TextAlign.end,
              "left" => TextAlign.left,
              "right" => TextAlign.right,
              "center" => TextAlign.center,
              "justify" => TextAlign.justify,
              _ => null,
            },
            style: TextStyle(
                color: (r.color != null) ? HexColor.fromHex(r.color!) : null,
                fontSize: r.fontSize,
                fontFamily: r.fontFamily,
                letterSpacing: r.letterSpacing,
                wordSpacing: r.wordSpacing,
                decoration: TextDecoration.combine(
                  [
                    if (r.textDecoration == "underline")
                      TextDecoration.underline,
                  ],
                ),
                fontWeight: switch (r.fontWeight) {
                  "normal" => FontWeight.normal,
                  "bold" => FontWeight.bold,
                  "100" => FontWeight.w100,
                  "200" => FontWeight.w200,
                  "300" => FontWeight.w300,
                  "400" => FontWeight.w400,
                  "500" => FontWeight.w500,
                  "600" => FontWeight.w600,
                  "700" => FontWeight.w700,
                  "800" => FontWeight.w800,
                  "900" => FontWeight.w900,
                  _ => FontWeight.normal,
                }),
          ),
        ),
      RenderTreeLink r => MouseRegion(
          onEnter: (event) {
            context.read<RenderScreenCubit>().setHoveredLink(r.link);
          },
          onExit: (event) {
            context.read<RenderScreenCubit>().clearHoveredLink();
          },
          child: GestureDetector(
            onTap: () {
              final uri = context
                  .read<BrowserCubit>()
                  .state
                  .currentTab!
                  .currentPage!
                  .uri;
              context
                  .read<BrowserCubit>()
                  .navigateToPage(uri.replace(path: r.link));
            },
            child: CommonStyleBlock(
              r.commonStyle,
              domHash: r.domElementHash,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final c in r.children) TreeRenderer(c),
                ],
              ),
            ),
          ),
        ),
      RenderTreeFlex r => CommonStyleBlock(
          r.commonStyle,
          domHash: r.domElementHash,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: switch (r.justifyContent) {
              "start" => MainAxisAlignment.start,
              "center" => MainAxisAlignment.center,
              "end" => MainAxisAlignment.end,
              "space-between" => MainAxisAlignment.spaceBetween,
              "space-around" => MainAxisAlignment.spaceAround,
              "space-evenly" => MainAxisAlignment.spaceEvenly,
              _ => MainAxisAlignment.start,
            },
            children: [
              for (final c in r.children) TreeRenderer(c),
            ],
          ),
        ),
      RenderTreeGrid r => CommonStyleBlock(
          r.commonStyle,
          domHash: r.domElementHash,
          child: GridView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: r.columnGap ?? 0.0,
              crossAxisSpacing: r.rowGap ?? 0.0,
            ),
            children: [
              for (final c in r.children) TreeRenderer(c),
            ],
          ),
        ),
      RenderTreeInputText r => BrowserInputTextField(
          r: r,
        ),
      RenderTreeInputSubmit r => BrowserInputSubmit(
          r: r,
        ),
      RenderTreeInputReset r => BrowserInputReset(
          r: r,
        ),
      RenderTreeInputFile r => BrowserInputFile(
          r: r,
        ),
      RenderTreeInputCheckbox r => BrowserInputCheckbox(
          r: r,
        ),
      RenderTreeInputRadio r => BrowserInputRadio(
          r: r,
        ),
      RenderTreeInputTextArea r => BrowserInputTextArea(
          r: r,
        ),
      RenderTreeInputHidden() => const SizedBox.shrink(),
      RenderTreeBox r => CommonStyleBlock(
          r.commonStyle,
          domHash: r.domElementHash,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in r.children)
                Align(
                  alignment: Alignment(0, 0),
                  child: TreeRenderer(c),
                ),
            ],
          ),
        ),
      RenderTreeScript() => SizedBox.shrink(),
    };
  }
}

class CommonStyleBlock extends StatelessWidget {
  const CommonStyleBlock(
    this.commonStyle, {
    super.key,
    required this.child,
    required this.domHash,
  });

  final CommonStyle? commonStyle;
  final Widget child;
  final int domHash;

  static final elementColor =
      Color.fromARGB(255, 176, 208, 211).withOpacity(0.9);
  static final marginColor =
      Color.fromARGB(255, 241, 166, 106).withOpacity(0.9);
  static final paddingColor =
      Color.fromARGB(255, 155, 197, 61).withOpacity(0.9);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: (commonStyle?.cursor == "pointer")
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: BlocBuilder<DevToolsCubit, DevToolsState>(
        buildWhen: (previous, current) {
          return current.selectedDomHash == domHash ||
              previous.selectedDomHash == domHash;
        },
        builder: (context, state) => DecoratedBox(
          decoration: BoxDecoration(
            color: (state.selectedDomHash == domHash)
                ? Colors.blue.shade800.withOpacity(0.4)
                : null,
          ),
          child: Container(
            alignment: (commonStyle?.isCentered ?? false)
                ? Alignment.center
                : Alignment.topLeft,
            constraints: BoxConstraints(
              maxWidth: commonStyle?.maxWidth ?? double.infinity,
              maxHeight: commonStyle?.maxHeight ?? double.infinity,
              minHeight: commonStyle?.minHeight ?? 0.0,
              minWidth: commonStyle?.minWidth ?? 0.0,
            ),
            decoration: BoxDecoration(
              color: (commonStyle?.backgroundColor != null)
                  ? HexColor.fromHex(commonStyle!.backgroundColor!)
                  : null,
              border: Border(
                bottom: (commonStyle?.borderBottomColor != null)
                    ? BorderSide(
                        width: commonStyle?.borderRightWidth ?? 0.0,
                        color:
                            HexColor.fromHex(commonStyle!.borderBottomColor!),
                      )
                    : BorderSide.none,
                left: (commonStyle?.borderLeftColor != null)
                    ? BorderSide(
                        width: commonStyle!.borderLeftWidth ?? 0.0,
                        color: HexColor.fromHex(commonStyle!.borderLeftColor!),
                      )
                    : BorderSide.none,
                top: (commonStyle?.borderTopColor != null)
                    ? BorderSide(
                        width: commonStyle?.borderTopWidth ?? 0.0,
                        color: HexColor.fromHex(commonStyle!.borderTopColor!),
                      )
                    : BorderSide.none,
                right: (commonStyle?.borderRightColor != null)
                    ? BorderSide(
                        width: commonStyle?.borderRightWidth ?? 0.0,
                        color: HexColor.fromHex(commonStyle!.borderRightColor!),
                      )
                    : BorderSide.none,
              ),
              borderRadius: (commonStyle?.borderRadius != null)
                  ? BorderRadius.circular(commonStyle!.borderRadius!)
                  : null,
            ),
            padding: EdgeInsets.only(
              bottom: commonStyle?.paddingBottom ?? 0.0,
              left: commonStyle?.paddingLeft ?? 0.0,
              top: commonStyle?.paddingTop ?? 0.0,
              right: commonStyle?.paddingRight ?? 0.0,
            ),
            margin: EdgeInsets.only(
              bottom: commonStyle?.marginBottom ?? 0.0,
              left: commonStyle?.marginLeft ?? 0.0,
              top: commonStyle?.marginTop ?? 0.0,
              right: commonStyle?.marginRight ?? 0.0,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
