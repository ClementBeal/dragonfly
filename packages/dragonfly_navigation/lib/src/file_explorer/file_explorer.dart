import 'dart:io';
import 'package:path/path.dart' as p;

enum FileType { file, directory }

class ExplorationResult {
  final String name;
  final Uri path;
  final int size;
  final FileType fileType;
  final DateTime lastModified;

  ExplorationResult({
    required this.name,
    required this.path,
    required this.size,
    required this.fileType,
    required this.lastModified,
  });
}

/// Explore a directory
///
/// Returns a list containing all the files and directories
/// sorted in natural order
Future<List<ExplorationResult>> exploreDirectory(Uri path) async {
  final directory = Directory.fromUri(path);
  final isDirectory = await directory.exists();

  if (!isDirectory) {
    throw Exception("Cannot explore a file : ${path.toString()}");
  }

  final fileSystemEntities = directory.listSync(followLinks: true);

  final a = fileSystemEntities.map((entity) async {
    final stat = await entity.stat();

    return ExplorationResult(
      name: p.basename(entity.path),
      path: Uri.parse(entity.path),
      size: stat.size,
      fileType: entity is File ? FileType.file : FileType.directory,
      lastModified: stat.changed,
    );
  });

  final List<ExplorationResult> result = await Future.wait(a);

  result.sort(
    (a, b) => a.name.compareTo(b.name),
  );

  return result;
}
