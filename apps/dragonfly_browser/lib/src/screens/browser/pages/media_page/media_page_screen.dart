import 'dart:io';

import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart';

class MediaPageScreen extends StatelessWidget {
  const MediaPageScreen({super.key, required this.page});

  final MediaPage page;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black87,
      ),
      child: ImageMediaPage(
        page: page,
      ),
    );
  }
}

class ImageMediaPage extends StatefulWidget {
  const ImageMediaPage({super.key, required this.page});

  final MediaPage page;

  @override
  State<ImageMediaPage> createState() => _ImageMediaPageState();
}

class _ImageMediaPageState extends State<ImageMediaPage> {
  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(widget.page.url),
      fit: BoxFit.fitHeight,
    );
  }
}
