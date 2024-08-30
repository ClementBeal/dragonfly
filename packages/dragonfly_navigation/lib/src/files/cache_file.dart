// TO DO -> must be passed with an initialize method
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:uuid/v4.dart';

final cacheDirectory = Directory("cache");

class FileCache {
  /// Save the file in the cache folder
  ///
  /// The [requestUri] is used to extract the extension
  ///
  /// The returned [uri] is pointing to the cached file
  static Uri cacheFile(Uri requestUri, Uint8List data) {
    final extension = p.extension(requestUri.path);
    final filename = p.setExtension(UuidV4().generate(), extension);

    final storeFilePath = p.join(
      cacheDirectory.path,
      filename,
    );

    final file = File(
      storeFilePath,
    )..writeAsBytes(data);

    return file.uri;
  }
}
