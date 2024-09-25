part of 'a_page.dart';

class FileExplorerPage extends Page {
  FileExplorerPage(this.result, {required super.uri, required super.status});

  final List<ExplorationResult> result;

  @override
  String? getTitle() {
    return "Index of ${uri.toString()}";
  }
}
