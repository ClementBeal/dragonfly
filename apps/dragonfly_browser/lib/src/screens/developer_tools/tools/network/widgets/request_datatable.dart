import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
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

          print(event);
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
        print(state.currentTab);
        listenNewTracker();
      },
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: const [
          DataColumn(
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
          DataColumn(
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
          DataColumn(
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
          DataColumn(
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
                    DataCell(Text("GET")),
                    DataCell(Text(Uri.parse(e.url).host)),
                    DataCell(Text(Uri.parse(e.url).path)),
                    DataCell(
                      Tooltip(
                        child: Text(
                          e.url,
                          overflow: TextOverflow.ellipsis,
                        ),
                        message: e.url,
                      ),
                    ),
                    DataCell(Text("text/html")),
                    DataCell(Text("15 KB")),
                    DataCell(Text("15 KB")),
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
