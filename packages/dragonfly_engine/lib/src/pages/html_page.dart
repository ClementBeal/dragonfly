part of 'a_page.dart';

class HtmlPage extends Page {
  final Document? document;
  final List<CSSStylesheet> stylesheets;
  final BrowserImage? favicon;

  HtmlPage({
    required super.uri,
    required super.status,
    super.guid,
    this.favicon,
    required this.document,
    required this.stylesheets,
  });

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
}
