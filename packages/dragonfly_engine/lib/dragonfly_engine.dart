/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'dart:io';

import 'package:dragonfly_browservault/dragonfly_browservault.dart';

export 'src/navigation/browser.dart' show Browser;
export 'src/navigation/tab.dart'
    show
        Tab,
        cssomBuilder,
        PageStatus,
        CSSStylesheet,
        FormData,
        FormDataFile,
        FormDataText;
export 'src/pages/a_page.dart'
    show Page, FileExplorerPage, HtmlPage, JsonPage, MediaPage;
export 'src/css/css_theme.dart' show FontSize, FontSizeType;
export 'src/css/cssom_builder.dart'
    show CSSRule, CssomBuilder, CssomNode, CssomTree;
export 'src/css/css_style.dart' show CssStyle;

export 'src/file_explorer/file_explorer.dart'
    show exploreDirectory, ExplorationResult, FileType;
export 'src/files/cache_file.dart' show FileCache;
export 'src/files/favicon.dart' show BrowserImage;

export 'src/render_tree/nodes/render_tree_node.dart'
    show
        CommonStyle,
        RenderTreeBox,
        RenderTreeObject,
        RenderTreeText,
        RenderTreeView,
        RenderTreeList,
        RenderTreeListItem,
        RenderTreeLink,
        RenderTreeFlex,
        RenderTreeGrid,
        RenderTreeImage,
        RenderTreeForm,
        RenderTreeInputText,
        RenderTreeInputSubmit,
        RenderTreeInputReset,
        RenderTreeInputFile,
        RenderTreeInputCheckbox,
        RenderTreeInputRadio,
        RenderTreeInputHidden,
        RenderTreeInputTextArea,
        RenderTreeInline,
        RenderTreeScript;

export 'src/render_tree/render_tree.dart' show BrowserRenderTree, RenderTree;
export 'src/utils/network_tracker.dart'
    show NetworkTracker, NetworkRequest, NetworkResponse;

late final Directory cacheDirectory;

void initializeEngine(String dbFolderPath, String cacheFolder) {
  initializeDb(dbFolderPath);
  cacheDirectory = Directory(cacheFolder);
}
