import 'dart:typed_data';

import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RenderImage extends StatefulWidget {
  const RenderImage({
    super.key,
    required this.node,
  });

  final RenderTreeImage node;

  @override
  State<RenderImage> createState() => _RenderImageState();
}

class _RenderImageState extends State<RenderImage> {
  late final Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();

    _imageFuture = context
        .read<BrowserCubit>()
        .state
        .currentTab!
        .downloadImage(widget.node.link);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        final imageData = snapshot.data;

        if (imageData == null) {
          return const SizedBox.shrink();
        }

        final isSVG = widget.node.link.endsWith("svg");

        if (isSVG) {
          return SvgPicture.memory(imageData);
        }

        return Image.memory(imageData);
      },
    );
  }
}
