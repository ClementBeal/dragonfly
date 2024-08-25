import 'dart:io';

import 'package:flutter/material.dart';

enum FileType { image, video, audio, json, txt, other }

class FileSpecialPage extends StatelessWidget {
  const FileSpecialPage({super.key, required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return switch (identifyFileType(uri)) {
      FileType.image => DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black87,
          ),
          child: Center(
            child: Image.file(
              File(
                uri.toFilePath(),
              ),
            ),
          ),
        ),
      FileType.txt => TextFileReader(filepath: uri.toFilePath()),
      _ => Text('Unsupported file type'),
    };
  }

  FileType identifyFileType(Uri uri) {
    final extension = uri.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return FileType.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return FileType.video;
      case 'mp3':
      case 'wav':
      case 'ogg':
        return FileType.audio;
      case 'json':
        return FileType.json;
      case 'txt':
        return FileType.txt;
      default:
        return FileType.other;
    }
  }
}

class TextFileReader extends StatefulWidget {
  const TextFileReader({super.key, required this.filepath});

  final String filepath;

  @override
  State<TextFileReader> createState() => _TextFileReaderState();
}

class _TextFileReaderState extends State<TextFileReader> {
  late final String content;

  @override
  void initState() {
    super.initState();

    content = File(widget.filepath).readAsStringSync();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Text(content));
  }
}
