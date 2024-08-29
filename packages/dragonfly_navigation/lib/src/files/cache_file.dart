// TO DO -> must be passed with an initialize method
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:uuid/v4.dart';

final cacheDirectory = Directory("cache");

class FileCache {
  static String cacheFile(Uri uri, Uint8List data) {
    final extension = p.extension(uri.path);
    final filename = p.setExtension(
      p.join(
        cacheDirectory.path,
        UuidV4().generate(),
      ),
      extension,
    );

    File(
      filename,
    ).writeAsBytes(data);

    return filename;
  }
}
