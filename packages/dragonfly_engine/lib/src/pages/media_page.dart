part of 'a_page.dart';

class MediaPage extends Page {
  MediaPage(
    this.isLocalMedia, {
    required super.uri,
    required super.status,
  });

  final bool isLocalMedia;

  @override
  String? getTitle() {
    return p.basename(uri.toFilePath());
  }
}
