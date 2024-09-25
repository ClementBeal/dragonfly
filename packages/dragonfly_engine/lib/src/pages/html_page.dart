part of 'a_page.dart';

class HtmlPage extends Page {
  final Document? document;
  final CssomTree? cssom;
  final BrowserImage? favicon;

  HtmlPage(
      {required super.url,
      required super.status,
      super.guid,
      this.favicon,
      required this.document,
      required this.cssom});

  HtmlPage copyWith({
    Document? document,
    PageStatus? status,
    CssomTree? cssom,
  }) {
    return HtmlPage(
      url: url,
      guid: guid,
      document: document ?? this.document,
      cssom: cssom ?? this.cssom,
      status: status ?? this.status,
    );
  }

  @override
  String? getTitle() {
    return document?.getElementsByTagName("title").firstOrNull?.text.trim();
  }
}
