import 'dart:io';

import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrowserImageRender extends StatelessWidget {
  const BrowserImageRender(this.faviconUri, {super.key, this.onEmpty});

  final BrowserImage? faviconUri;
  final Widget Function()? onEmpty;

  @override
  Widget build(BuildContext context) {
    if (faviconUri == null) {
      return onEmpty?.call() ?? const SizedBox.shrink();
    }

    if (faviconUri!.mimetype == "image/svg+xml") {
      return SvgPicture.file(
        File.fromUri(faviconUri!.path),
        // fit: BoxFit.cover,
      );
    }

    return Image.file(File.fromUri(faviconUri!.path));
  }
}
