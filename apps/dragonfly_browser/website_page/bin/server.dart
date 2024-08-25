import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

void main(List<String> args) async {
  // Assume your current directory is the root of your Dart project
  final pagesDir = Directory(r'pages');
  print(pagesDir.absolute.path);

  // Create a handler that serves files from the 'website_project/pages' directory
  final handler = createStaticHandler(
    pagesDir.absolute.path,
    defaultDocument: 'index.html',
    listDirectories: false,
    useHeaderBytesForContentType: true,
  );

  // Start the server on localhost, port 8080
  final server = await shelf_io.serve(handler, 'localhost', 8088);

  print('Serving at http://${server.address.host}:${server.port}');
}
