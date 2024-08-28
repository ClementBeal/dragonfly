import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class NetworkRequestDataTable extends StatelessWidget {
  const NetworkRequestDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable2(
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
      rows: [
        DataRow(
          cells: [
            DataCell(
              StatusCodeChip(statusCode: 201),
            ),
            const DataCell(Text("GET")),
            const DataCell(Text("example.com")),
            const DataCell(Text("/index.html")),
            const DataCell(Text("text/html")),
            const DataCell(Text("15 KB")),
            const DataCell(Text("15 KB")),
            const DataCell(Text("120 ms")),
          ],
        ),
        DataRow(
          cells: [
            DataCell(
              StatusCodeChip(statusCode: 404),
            ),
            const DataCell(Text("GET")),
            const DataCell(Text("example.com")),
            const DataCell(Text("/missing.png")),
            const DataCell(Text("image/png")),
            const DataCell(Text("0 KB")),
            const DataCell(Text("0 KB")),
            const DataCell(Text("50 ms")),
          ],
        ),
        DataRow(
          cells: [
            DataCell(
              StatusCodeChip(statusCode: 304),
            ),
            const DataCell(Text("GET")),
            const DataCell(Text("example.com")),
            const DataCell(Text("/style.css")),
            const DataCell(Text("text/css")),
            const DataCell(Text("1.5 KB")),
            const DataCell(Text("0 KB")),
            const DataCell(Text("80 ms")),
          ],
        ),
        DataRow(
          cells: [
            DataCell(
              StatusCodeChip(statusCode: 200),
            ),
            const DataCell(Text("POST")),
            const DataCell(Text("example.com")),
            const DataCell(Text("/api/data")),
            const DataCell(Text("application/json")),
            const DataCell(Text("5 KB")),
            const DataCell(Text("5 KB")),
            const DataCell(Text("150 ms")),
          ],
        ),
      ],
    );
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
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
