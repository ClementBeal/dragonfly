import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/browser_theme.dart';
import 'package:dragonfly/src/screens/browser/helpers/color_utils.dart';
import 'package:dragonfly/src/screens/browser/pages/file_explorer_page.dart';
import 'package:dragonfly/src/screens/browser/pages/media_page/media_page_screen.dart';
import 'package:dragonfly/src/screens/lobby/lobby_screen.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart' hide Element;
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
                  initialUrl: path.toFilePath(),
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

            if (tab == null || tab.currentPage == null) {
              return const LobbyScreen();
            }

            final currentPage = tab.currentPage!;

            return switch (currentPage.status) {
              PageStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              PageStatus.error => const Center(
                  child: Text("Error"),
                ),
              PageStatus.success => SizedBox.expand(
                  child: switch (currentPage) {
                    FileExplorerPage p => FileExplorerPageScreen(
                        page: p,
                        tab: tab,
                      ),
                    HtmlPage page => CSSOMProvider(
                        cssom: currentPage.cssom ?? cssomBuilder.browserStyle!,
                        child: (currentPage.document!.documentElement != null)
                            ? Builder(builder: (context) {
                                // TO DO
                                // dirty hack for testing purpose
                                // it has to be moded to a special package
                                // called `dragonfly_renderer`

                                final renderTree = BrowserRenderTree(
                                  dom: currentPage.document!,
                                  cssom: currentPage.cssom!,
                                  initialRoute: page.url,
                                ).parse();

                                return TreeRenderer(renderTree.child);
                              })
                            : const SizedBox.shrink(),
                      ),
                    MediaPage p => MediaPageScreen(page: p),
                  },
                ),
            };
          },
        ),
      ),
    );
  }
}

class TreeRenderer extends StatelessWidget {
  const TreeRenderer(this.renderNode, {super.key});

  final RenderTreeObject renderNode;

  @override
  Widget build(BuildContext context) {
    if (renderNode is RenderTreeGrid) {
      print((renderNode as RenderTreeGrid).rowGap);
      print((renderNode as RenderTreeGrid).columnGap);
    }

    return switch (renderNode) {
      RenderTreeList r => Container(
          decoration: BoxDecoration(
            color: (r.backgroundColor != null)
                ? HexColor.fromHex(r.backgroundColor!)
                : null,
            border: Border(
              bottom: (r.borderBottomColor != null)
                  ? BorderSide(
                      width: r.borderRightWidth ?? 0.0,
                      color: HexColor.fromHex(r.borderBottomColor!),
                    )
                  : BorderSide.none,
              left: (r.borderLeftColor != null)
                  ? BorderSide(
                      width: r.borderLeftWidth ?? 0.0,
                      color: HexColor.fromHex(r.borderLeftColor!),
                    )
                  : BorderSide.none,
              top: (r.borderTopColor != null)
                  ? BorderSide(
                      width: r.borderTopWidth ?? 0.0,
                      color: HexColor.fromHex(r.borderTopColor!),
                    )
                  : BorderSide.none,
              right: (r.borderRightColor != null)
                  ? BorderSide(
                      width: r.borderRightWidth ?? 0.0,
                      color: HexColor.fromHex(r.borderRightColor!),
                    )
                  : BorderSide.none,
            ),
            borderRadius: (r.borderRadius != null)
                ? BorderRadius.circular(r.borderRadius!)
                : null,
          ),
          margin: EdgeInsets.only(
            bottom: r.marginBottom ?? 0.0,
            left: r.marginLeft ?? 0.0,
            top: r.marginTop ?? 0.0,
            right: r.marginRight ?? 0.0,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: r.paddingBottom ?? 0.0,
              left: r.paddingLeft ?? 0.0,
              top: r.paddingTop ?? 0.0,
              right: r.paddingRight ?? 0.0,
            ),
            child: Column(
              // spacing: 6,
              mainAxisSize: MainAxisSize.min,
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
                        decoration: BoxDecoration(
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
        ),
      RenderTreeListItem r => Container(
          decoration: BoxDecoration(
            color: (r.backgroundColor != null)
                ? HexColor.fromHex(r.backgroundColor!)
                : null,
            border: Border(
              bottom: (r.borderBottomColor != null)
                  ? BorderSide(
                      width: r.borderRightWidth ?? 0.0,
                      color: HexColor.fromHex(r.borderBottomColor!),
                    )
                  : BorderSide.none,
              left: (r.borderLeftColor != null)
                  ? BorderSide(
                      width: r.borderLeftWidth ?? 0.0,
                      color: HexColor.fromHex(r.borderLeftColor!),
                    )
                  : BorderSide.none,
              top: (r.borderTopColor != null)
                  ? BorderSide(
                      width: r.borderTopWidth ?? 0.0,
                      color: HexColor.fromHex(r.borderTopColor!),
                    )
                  : BorderSide.none,
              right: (r.borderRightColor != null)
                  ? BorderSide(
                      width: r.borderRightWidth ?? 0.0,
                      color: HexColor.fromHex(r.borderRightColor!),
                    )
                  : BorderSide.none,
            ),
            borderRadius: (r.borderRadius != null)
                ? BorderRadius.circular(r.borderRadius!)
                : null,
          ),
          margin: EdgeInsets.only(
            bottom: r.marginBottom ?? 0.0,
            left: r.marginLeft ?? 0.0,
            top: r.marginTop ?? 0.0,
            right: r.marginRight ?? 0.0,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: r.paddingBottom ?? 0.0,
              left: r.paddingLeft ?? 0.0,
              top: r.paddingTop ?? 0.0,
              right: r.paddingRight ?? 0.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in r.children) TreeRenderer(c),
              ],
            ),
          ),
        ),
      RenderTreeInline r => Row(
          mainAxisSize: MainAxisSize.max,
          children: r.children.map((a) => TreeRenderer(a)).toList(),
        ),
      RenderTreeImage r => Image.network(r.link),
      RenderTreeView r => DecoratedBox(
          decoration: BoxDecoration(
            color: HexColor.fromHex(r.backgroundColor),
          ),
          child: SizedBox.expand(
            child: SingleChildScrollView(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TreeRenderer(r.child),
                ],
              ),
            ),
          ),
        ),
      RenderTreeText r => Text(
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
      RenderTreeLink r => GestureDetector(
          onTap: () {
            final a = Uri.parse(context
                .read<BrowserCubit>()
                .state
                .currentTab!
                .currentPage!
                .url);
            context
                .read<BrowserCubit>()
                .navigateToPage(a.replace(path: r.link).toString());
          },
          child: Column(
            children: r.children.map((e) => TreeRenderer(e)).toList(),
          ),
        ),
      RenderTreeFlex r => Container(
          color: (r.backgroundColor != null)
              ? HexColor.fromHex(r.backgroundColor!)
              : null,
          margin: EdgeInsets.only(
            bottom: r.marginBottom ?? 0.0,
            left: r.marginLeft ?? 0.0,
            top: r.marginTop ?? 0.0,
            right: r.marginRight ?? 0.0,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: (r.backgroundColor != null)
                  ? HexColor.fromHex(r.backgroundColor!)
                  : null,
              border: Border(
                bottom: (r.borderBottomColor != null)
                    ? BorderSide(
                        width: r.borderRightWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderBottomColor!),
                      )
                    : BorderSide.none,
                left: (r.borderLeftColor != null)
                    ? BorderSide(
                        width: r.borderLeftWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderLeftColor!),
                      )
                    : BorderSide.none,
                top: (r.borderTopColor != null)
                    ? BorderSide(
                        width: r.borderTopWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderTopColor!),
                      )
                    : BorderSide.none,
                right: (r.borderRightColor != null)
                    ? BorderSide(
                        width: r.borderRightWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderRightColor!),
                      )
                    : BorderSide.none,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: r.paddingBottom ?? 0.0,
                left: r.paddingLeft ?? 0.0,
                top: r.paddingTop ?? 0.0,
                right: r.paddingRight ?? 0.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: switch (r.justifyContent) {
                  "start" => MainAxisAlignment.start,
                  _ => MainAxisAlignment.start,
                },
                children: [
                  // for (final c in r.children) TreeRenderer(c),
                ],
              ),
            ),
          ),
        ),
      RenderTreeGrid r => Container(
          color: (r.backgroundColor != null)
              ? HexColor.fromHex(r.backgroundColor!)
              : null,
          margin: EdgeInsets.only(
            bottom: r.marginBottom ?? 0.0,
            left: r.marginLeft ?? 0.0,
            top: r.marginTop ?? 0.0,
            right: r.marginRight ?? 0.0,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: (r.backgroundColor != null)
                  ? HexColor.fromHex(r.backgroundColor!)
                  : null,
              borderRadius: (r.borderRadius != null)
                  ? BorderRadius.circular(r.borderRadius!)
                  : null,
              border: Border(
                bottom: (r.borderBottomColor != null)
                    ? BorderSide(
                        width: r.borderRightWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderBottomColor!),
                      )
                    : BorderSide.none,
                left: (r.borderLeftColor != null)
                    ? BorderSide(
                        width: r.borderLeftWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderLeftColor!),
                      )
                    : BorderSide.none,
                top: (r.borderTopColor != null)
                    ? BorderSide(
                        width: r.borderTopWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderTopColor!),
                      )
                    : BorderSide.none,
                right: (r.borderRightColor != null)
                    ? BorderSide(
                        width: r.borderRightWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderRightColor!),
                      )
                    : BorderSide.none,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: r.paddingBottom ?? 0.0,
                left: r.paddingLeft ?? 0.0,
                top: r.paddingTop ?? 0.0,
                right: r.paddingRight ?? 0.0,
              ),
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
          ),
        ),
      RenderTreeBox r => Container(
          color: (r.backgroundColor != null)
              ? HexColor.fromHex(r.backgroundColor!)
              : null,
          alignment: Alignment.center,
          constraints: BoxConstraints(
            maxWidth: r.maxWidth ?? double.infinity,
            maxHeight: r.maxHeight ?? double.infinity,
          ),
          margin: EdgeInsets.only(
            bottom: r.marginBottom ?? 0.0,
            left: r.marginLeft ?? 0.0,
            top: r.marginTop ?? 0.0,
            right: r.marginRight ?? 0.0,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: (r.backgroundColor != null)
                  ? HexColor.fromHex(r.backgroundColor!)
                  : null,
              border: Border(
                bottom: (r.borderBottomColor != null)
                    ? BorderSide(
                        width: r.borderRightWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderBottomColor!),
                      )
                    : BorderSide.none,
                left: (r.borderLeftColor != null)
                    ? BorderSide(
                        width: r.borderLeftWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderLeftColor!),
                      )
                    : BorderSide.none,
                top: (r.borderTopColor != null)
                    ? BorderSide(
                        width: r.borderTopWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderTopColor!),
                      )
                    : BorderSide.none,
                right: (r.borderRightColor != null)
                    ? BorderSide(
                        width: r.borderRightWidth ?? 0.0,
                        color: HexColor.fromHex(r.borderRightColor!),
                      )
                    : BorderSide.none,
              ),
              borderRadius: (r.borderRadius != null)
                  ? BorderRadius.circular(r.borderRadius!)
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: r.paddingBottom ?? 0.0,
                left: r.paddingLeft ?? 0.0,
                top: r.paddingTop ?? 0.0,
                right: r.paddingRight ?? 0.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final c in r.children) TreeRenderer(c),
                ],
              ),
            ),
          ),
        ),
    };
  }
}
