import 'dart:io';
import 'dart:math';

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
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(
                    "Index of ${page.url}",
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
                  DataTable(
                    dataTextStyle: const TextStyle(
                        // color: Colors.white,
                        ),
                    columns: [
                      const DataColumn(label: Text("Name")),
                      const DataColumn(label: Text("Size")),
                      const DataColumn(label: Text("Last Modified")),
                    ],
                    rows: page.result
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      (e.fileType == FileType.file)
                                          ? Icons.file_copy
                                          : Icons.folder,
                                      size: 12,
                                    ),
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
                              if (e.fileType == FileType.file)
                                DataCell(Text(formatBytes(e.size)))
                              else
                                const DataCell(Text("")),
                              DataCell(Text(e.lastModified.toString())),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}
