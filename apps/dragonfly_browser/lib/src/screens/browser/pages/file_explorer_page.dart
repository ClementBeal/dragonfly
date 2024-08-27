import 'dart:io';
import 'dart:math';

import 'package:dragonfly/src/constants/file_constants.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/favorites/favorite_bar.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FileExplorerPageScreen extends StatelessWidget {
  const FileExplorerPageScreen({super.key, required this.page});

  final FileExplorerPage page;

  @override
  Widget build(BuildContext context) {
    // TODO : may not work on Windows
    var parentDirectory = Directory(page.url).parent;
    final canGoToParent = parentDirectory.path != ".";

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black87,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Text(
                      "Index of ${Uri.parse(Directory(page.url).path).toFilePath()}",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (canGoToParent)
                      TextButton(
                        onPressed: () {
                          context.read<BrowserCubit>().navigateToPage(
                                parentDirectory.uri.toFilePath(),
                              );
                        },
                        child: const Text(
                          "Up to higher level directory",
                        ),
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 1 + page.result.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const Row(
                            children: [
                              Flexible(
                                  flex: 5,
                                  fit: FlexFit.tight,
                                  child: Text("Name")),
                              Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Text("Size")),
                              Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: Text("Last Modified")),
                            ],
                          );
                        }

                        final e = page.result[index - 1];

                        return Row(
                          children: [
                            Flexible(
                              flex: 5,
                              fit: FlexFit.tight,
                              child: Row(
                                spacing: 4,
                                // mainAxisSize: MainAxisSize.min,
                                children: [
                                  FileSystemEntityIcon(result: e),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<BrowserCubit>()
                                          .navigateToPage(
                                            e.path.toString(),
                                          );
                                    },
                                    child: Text(e.name),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: (e.fileType == FileType.file)
                                  ? Text(formatBytes(e.size))
                                  : const Text(""),
                            ),
                            Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: Text(
                                e.lastModified.toString(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FileSystemEntityIcon extends StatelessWidget {
  const FileSystemEntityIcon({
    super.key,
    required this.result,
  });

  final ExplorationResult result;

  @override
  Widget build(BuildContext context) {
    const iconSize = 18.0;

    if ((result.fileType == FileType.file)) {
      final extension = result.name.split(".").last;

      if (audioExtensions.contains(extension)) {
        return Icon(
          Icons.audiotrack,
          size: iconSize,
          color: Colors.green.shade600,
        );
      } else if (videoExtensions.contains(extension)) {
        return Icon(
          Icons.movie_outlined,
          size: iconSize,
          color: Colors.orange.shade800,
        );
      } else if (imageExtensions.contains(extension)) {
        return Icon(
          Icons.image,
          size: iconSize,
          color: Colors.blue.shade600,
        );
      }

      return const Icon(
        Icons.file_copy,
        size: iconSize,
      );
    } else if (result.fileType == FileType.directory) {
      return Icon(
        Icons.folder,
        size: iconSize,
        color: Colors.yellow.shade700,
      );
    }

    return SizedBox.shrink();
  }
}

String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}
