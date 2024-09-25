import 'dart:io';

import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrowserImageRender extends StatelessWidget {
  const BrowserImageRender(
    this.image, {
    super.key,
    this.onEmpty,
  });

  final BrowserImage? image;
  final Widget Function()? onEmpty;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return onEmpty?.call() ?? const SizedBox.shrink();
    }

    if (image!.mimetype == "image/svg+xml") {
      return SvgPicture.file(
        File.fromUri(image!.path),
      );
    }

    return Image.file(
      File.fromUri(image!.path),
    );
  }
}
