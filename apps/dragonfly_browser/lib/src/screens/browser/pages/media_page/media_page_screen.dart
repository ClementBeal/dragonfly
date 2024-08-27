import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';

class MediaPageScreen extends StatelessWidget {
  const MediaPageScreen({super.key, required this.page});

  final MediaPage page;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
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
  bool isZooming = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _zoomAtPosition(TapUpDetails details) {
    final tapPosition = details.localPosition;

    final newScrollY =
        (tapPosition.dy * _scrollController.position.maxScrollExtent) /
            context.size!.height;

    _scrollController.jumpTo(newScrollY);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          isZooming ? SystemMouseCursors.zoomOut : SystemMouseCursors.zoomIn,
      child: GestureDetector(
        onTapUp: (details) {
          setState(() {
            isZooming = !isZooming;
          });

          if (isZooming) {
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                _zoomAtPosition(details);
              },
            );
          }
        },
        child: (isZooming)
            ? SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.file(
                      File(widget.page.url),
                    ),
                  ],
                ),
              )
            : Image.file(
                File(widget.page.url),
              ),
      ),
    );
  }
}
