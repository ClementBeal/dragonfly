import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/pages/file_explorer_page.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
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

  NetworkRequest? selectedRequest;

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
      child: Column(
        children: [
          Expanded(
            child: DataTable2(
              showCheckboxColumn: false,
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
                DataColumn2(
                  size: ColumnSize.S,
                  label: Text(
                    "Is Cached",
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
                        onSelectChanged: (value) {
                          setState(() {
                            selectedRequest = (value ?? false) ? e : null;
                          });
                        },
                        cells: [
                          DataCell(
                            StatusCodeChip(
                                statusCode: e.response?.statusCode ?? 0),
                          ),
                          DataCell(TextWithTooltip((e.response != null)
                              ? e.response!.isCached.toString()
                              : "")),
                          DataCell(TextWithTooltip(e.method)),
                          DataCell(TextWithTooltip(Uri.parse(e.url).host)),
                          DataCell(TextWithTooltip(Uri.parse(e.url).path)),
                          DataCell(TextWithTooltip(e.url)),
                          DataCell(TextWithTooltip("text/html")),
                          DataCell(
                            TextWithTooltip(
                              formatBytes(
                                e.response?.contentLengthCompressed ?? 0,
                                decimals: 0,
                              ),
                            ),
                          ),
                          DataCell(
                            TextWithTooltip(
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
          ),
          if (selectedRequest != null)
            SelectionArea(
              child: SizedBox(
                height: 220,
                child: RequestDetailsPanel(
                  request: selectedRequest!,
                ),
              ),
            ),
        ],
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

class TextWithTooltip extends StatelessWidget {
  const TextWithTooltip(this.text, {super.key});

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

class RequestDetailsPanel extends StatelessWidget {
  const RequestDetailsPanel({super.key, required this.request});

  final NetworkRequest request;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 2,
            color: Colors.green.shade800,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              spacing: 12,
              children: [
                Text(request.method),
                Expanded(child: TextWithTooltip(request.url)),
              ],
            ),
            Divider(),
            Table(
              children: [
                TableRow(
                  children: [
                    Text("Status"),
                    Text(request.response!.statusCode.toString()),
                  ],
                ),
              ],
            ),
            Divider(),
            HeadersTable(
              title: "Request headers",
              headers: request.headers,
              headerLength: request.headersLength,
            ),
            Divider(),
            if (request.response != null)
              HeadersTable(
                title: "Response headers",
                headers: request.response!.headers,
                headerLength: request.response!.headersLength,
              ),
          ],
        ),
      ),
    );
  }
}

class HeadersTable extends StatefulWidget {
  const HeadersTable({
    super.key,
    required this.headers,
    required this.title,
    required this.headerLength,
  });

  final Map<String, String> headers;
  final int headerLength;
  final String title;

  @override
  State<HeadersTable> createState() => _HeadersTableState();
}

class _HeadersTableState extends State<HeadersTable> {
  bool isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    setState(() {
                      isOpen = !isOpen;
                    });
                  },
                  child: Icon(
                      (isOpen) ? Icons.arrow_drop_down : Icons.arrow_right)),
              Text(
                "${widget.title} (${formatBytes(widget.headerLength, decimals: 0)})",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (isOpen)
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.headers.length,
            separatorBuilder: (context, index) => SizedBox(height: 4),
            itemBuilder: (context, index) {
              final entry = widget.headers.entries.elementAt(index);

              return HeaderTableRow(entry: entry);
            },
          ),
      ],
    );
  }
}

class HeaderTableRow extends StatefulWidget {
  const HeaderTableRow({
    super.key,
    required this.entry,
  });

  final MapEntry<String, String> entry;

  @override
  State<HeaderTableRow> createState() => _HeaderTableRowState();
}

class _HeaderTableRowState extends State<HeaderTableRow> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => isHovered = true),
      onExit: (event) => setState(() => isHovered = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: (isHovered)
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: capitalizeHttpHeader(widget.entry.key),
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                TextSpan(text: "   :   "),
                TextSpan(
                  text: widget.entry.value,
                  style: TextStyle(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String capitalizeHttpHeader(String header) {
  if (header.isEmpty) {
    return header; // Return empty string if input is empty
  }
  return header
      .split('-')
      .map((part) => part.trim().toLowerCase())
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join('-');
}
