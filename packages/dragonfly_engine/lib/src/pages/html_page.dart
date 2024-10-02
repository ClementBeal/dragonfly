part of 'a_page.dart';

class HtmlPage extends Page {
  final Document? document;
  final List<CSSStylesheet> stylesheets;
  final BrowserImage? favicon;

  late RenderTree? _renderTree;

  HtmlPage({
    required super.uri,
    required super.status,
    super.guid,
    this.favicon,
    required this.document,
    required this.stylesheets,
  }) {
    if (status == PageStatus.success) {
      _renderTree = BrowserRenderTree(
        dom: document!,
        cssom: CssomBuilder().parse(
          stylesheets
              .whereType<CSSStylesheet>()
              .map((e) => e.content)
              .join("\n"),
        ),
        initialRoute: uri.toString(),
      ).parse();
    }
  }

  HtmlPage copyWith({
    Document? document,
    PageStatus? status,
    List<CSSStylesheet>? stylesheets,
  }) {
    return HtmlPage(
      uri: uri,
      guid: guid,
      document: document ?? this.document,
      stylesheets: stylesheets ?? this.stylesheets,
      status: status ?? this.status,
    );
  }

  @override
  String? getTitle() {
    return document?.getElementsByTagName("title").firstOrNull?.text.trim();
  }

  RenderTree? get renderTree => _renderTree;
}
