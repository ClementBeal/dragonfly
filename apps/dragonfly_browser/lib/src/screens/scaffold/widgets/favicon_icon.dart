import 'dart:io';

import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrowserImageRender extends StatelessWidget {
  const BrowserImageRender(this.faviconUri, {super.key});

  final BrowserImage? faviconUri;

  @override
  Widget build(BuildContext context) {
    if (faviconUri == null) {
      return SizedBox.shrink();
    }

    if (faviconUri!.mimetype == "image/svg+xml") {
      return SvgPicture.file(
        File.fromUri(faviconUri!.path),
      );
    }

    return Image.file(File.fromUri(faviconUri!.path));
  }
}
