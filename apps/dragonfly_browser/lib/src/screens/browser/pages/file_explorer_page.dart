import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dragonfly/src/constants/file_constants.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/pages/cubit/file_explorer_cubit.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class FileExplorerPageScreen extends StatelessWidget {
  const FileExplorerPageScreen(
      {super.key, required this.page, required this.tab});

  final FileExplorerPage page;
  final Tab? tab;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black87,
      ),
      child: FileExplorerCard(tab: tab, page: page),
    );
  }
}

class FileExplorerCard extends StatelessWidget {
  const FileExplorerCard({
    super.key,
    required this.page,
    required this.tab,
  });

  final FileExplorerPage page;
  final Tab? tab;

  @override
  Widget build(BuildContext context) {
    // TODO : may not work on Windows
    var parentDirectory = Directory.fromUri(page.uri).parent;
    final canGoToParent = parentDirectory.path != ".";
    final hasHiddenFile = page.result.firstWhereOrNull(
          (element) => element.name.startsWith("."),
        ) !=
        null;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    "Index of ${page.uri.toFilePath()}",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (canGoToParent)
                        TextButton.icon(
                          icon: const Icon(Icons.arrow_upward_rounded),
                          onPressed: () {
                            context.read<BrowserCubit>().navigateToPage(
                                  parentDirectory.absolute.uri,
                                );
                          },
                          label: const Text(
                            "Up to higher level directory",
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (hasHiddenFile && tab != null)
                        BlocBuilder<FileExplorerCubit, FileExplorerState>(
                          builder: (context, state) => Row(
                            children: [
                              Checkbox(
                                value:
                                    state.showHiddenFiles[tab!.guid] ?? false,
                                onChanged: (value) {
                                  context
                                      .read<FileExplorerCubit>()
                                      .toggleShowHiddenFiles(tab!.guid);
                                },
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    context
                                        .read<FileExplorerCubit>()
                                        .toggleShowHiddenFiles(tab!.guid);
                                  },
                                  child: (state.showHiddenFiles[tab!.guid] ??
                                          false)
                                      ? const Text("Do not show hidden files")
                                      : const Text("Show hidden files"),
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                  BlocBuilder<FileExplorerCubit, FileExplorerState>(
                      builder: (context, state) {
                    var results = page.result;

                    if (tab != null &&
                        (state.showHiddenFiles[tab!.guid] ?? false) == false) {
                      results = results
                          .whereNot((f) => f.name.startsWith("."))
                          .toList();
                    }

                    return ExplorerResultListView(
                      explorerResults: results,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExplorerResultListView extends StatelessWidget {
  const ExplorerResultListView({
    super.key,
    required this.explorerResults,
  });

  final List<ExplorationResult> explorerResults;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 1 + explorerResults.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const HeaderRow();
        }

        final e = explorerResults[index - 1];

        return Row(
          children: [
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Row(
                children: [
                  FileSystemEntityIcon(result: e),
                  SizedBox(width: 4),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final extension = e.path.toFilePath().split(".").last;

                        if (e.fileType == FileType.file &&
                            (extension != "json" &&
                                !audioExtensions.contains(extension) &&
                                !videoExtensions.contains(extension) &&
                                !imageExtensions.contains(extension))) {
                          launchUrl(e.path);
                        } else {
                          context.read<BrowserCubit>().navigateToPage(
                                e.path,
                              );
                        }
                      },
                      child: Text(
                        e.name,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
    );
  }
}

class HeaderRow extends StatelessWidget {
  const HeaderRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    return const Row(
      children: [
        Flexible(
            flex: 5,
            fit: FlexFit.tight,
            child: Text(
              "Name",
              style: style,
            )),
        Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(
              "Size",
              style: style,
            )),
        Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Text(
              "Last Modified",
              style: style,
            )),
      ],
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

    return const SizedBox.shrink();
  }
}

String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)}${suffixes[i]}';
}
