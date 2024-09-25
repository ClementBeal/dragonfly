part of 'a_page.dart';

class JsonPage extends Page {
  JsonPage({
    required super.uri,
    required super.status,
    super.guid,
  });

  @override
  String? getTitle() {
    return p.basename(uri.toFilePath());
  }
}
