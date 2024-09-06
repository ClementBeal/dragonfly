part of 'a_page.dart';

class JsonPage extends Page {
  JsonPage({
    required super.url,
    required super.status,
    super.guid,
  });

  @override
  String? getTitle() {
    return p.basename(url);
  }
}
