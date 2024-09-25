
enum ImageType { svg, image }

/// Contains the data of an image or a svg
///  The [path] is
/// The [mimetype] will be use to
class BrowserImage {
  final Uri path;
  final String mimetype;
  bool isMemoryImage = false;

  BrowserImage({required this.path, required this.mimetype});

  // Uint8List? decodeBase64() {
  //   final href = path.toString();
  //   if (type != ImageType.url && href.contains(';base64,')) {
  //     final base64Data = href.split(';base64,').last;
  //     return base64Decode(base64Data);
  //   }
  //   return null; // Not a Base64-encoded favicon
  // }
}
