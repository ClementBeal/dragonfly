// TO DO -> must be passed with an initialize method
import 'dart:io';
import 'dart:typed_data';
import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
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

  /// Fetch a cached image
  ///
  /// Return `null` if the file is not present in the cache
  static BrowserImage? getCacheFile(Uri requestUri) {
    final result = FileCacheRepo(db).getFileFromCache(
      requestUri.toString(),
    );

    if (result == null) return null;

    return BrowserImage(
      path: Uri.parse(p.join(cacheDirectory.path, result.$1)),
      mimetype: result.$2,
    );
  }
}
