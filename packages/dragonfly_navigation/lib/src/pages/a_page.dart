import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:html/dom.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

part 'html_page.dart';
part 'file_explorer_page.dart';
part 'json_page.dart';
part 'media_page.dart';

sealed class Page {
  late final String guid;
  final String url;
  final PageStatus status;

  Page({
    required this.url,
    required this.status,
    String? guid,
  }) {
    this.guid = guid ?? Uuid().v4();
  }

  String? getTitle();
}
