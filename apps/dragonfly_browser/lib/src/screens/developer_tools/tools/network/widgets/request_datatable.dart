import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/pages/file_explorer_page.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkRequestDataTable extends StatefulWidget {
  const NetworkRequestDataTable({super.key});

  @override
  State<NetworkRequestDataTable> createState() =>
      _NetworkRequestDataTableState();
}

class _NetworkRequestDataTableState extends State<NetworkRequestDataTable> {
  late List<NetworkRequest> requests;
  StreamSubscription<NetworkRequest>? stream;

  @override
  void initState() {
    super.initState();

    listenNewTracker();
  }

  void listenNewTracker() {
    stream?.cancel();

    setState(() {
      requests =
          context.read<BrowserCubit>().state.currentTab?.tracker.history ?? [];

      stream = context
          .read<BrowserCubit>()
          .state
          .currentTab
          ?.tracker
          .requestStream
          .listen(
        (event) {
          setState(() {
            requests = [...requests, event];
          });
        },
      );
    });
  }

  @override
  void dispose() {
    stream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BrowserCubit, Browser>(
      listener: (context, state) {
        listenNewTracker();
      },
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: const [
          DataColumn2(
            label: Text(
              "Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Method",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn2(
            size: ColumnSize.L,
            label: Text(
              "Domain",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "File",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn2(
            size: ColumnSize.L,
            label: Text(
              "URL",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Type",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Transferred",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Size",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn2(
            size: ColumnSize.S,
            label: Text(
              "Duration",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: requests
            .map((e) => DataRow(
                  cells: [
                    DataCell(
                      StatusCodeChip(statusCode: e.response?.statusCode ?? 0),
                    ),
                    DataCell(TextDatacell("GET")),
                    DataCell(TextDatacell(Uri.parse(e.url).host)),
                    DataCell(TextDatacell(Uri.parse(e.url).path)),
                    DataCell(TextDatacell(e.url)),
                    DataCell(TextDatacell("text/html")),
                    DataCell(
                      TextDatacell(
                        formatBytes(
                          e.response?.contentLengthCompressed ?? 0,
                          decimals: 0,
                        ),
                      ),
                    ),
                    DataCell(
                      TextDatacell(
                        formatBytes(
                          e.response?.contentLengthUncompressed ?? 0,
                          decimals: 0,
                        ),
                      ),
                    ),
                    DataCell(RequestDurationCell(
                      request: e,
                    )),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class RequestDurationCell extends StatelessWidget {
  const RequestDurationCell({super.key, required this.request});

  final NetworkRequest request;

  @override
  Widget build(BuildContext context) {
    if (request.response == null) {
      return Text("");
    } else {
      var requestDuration = request.response!.timestamp
          .difference(request.timestamp)
          .inMilliseconds;
      return Text("${requestDuration}ms");
    }
  }
}

class StatusCodeChip extends StatelessWidget {
  const StatusCodeChip({super.key, required this.statusCode});

  final int statusCode;

  @override
  Widget build(BuildContext context) {
    final color = switch (statusCode) {
      >= 200 && < 300 => Colors.green,
      >= 400 && < 500 => Colors.red,
      _ => Colors.transparent, // TO DO : probably bad
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
        child: Text(
          "$statusCode",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class TextDatacell extends StatelessWidget {
  const TextDatacell(this.text, {super.key});

  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: text,
      child: Text(
        text!,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
