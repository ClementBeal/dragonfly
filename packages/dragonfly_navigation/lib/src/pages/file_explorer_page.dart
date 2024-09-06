part of 'a_page.dart';

class FileExplorerPage extends Page {
  FileExplorerPage(this.result, {required super.url, required super.status});

  final List<ExplorationResult> result;

  @override
  String? getTitle() {
    return "Index of ${url.toString()}";
  }
}
