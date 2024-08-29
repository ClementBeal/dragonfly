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
      rows: const [
        DataRow(
          cells: [
            DataCell(
              StatusCodeChip(statusCode: 201),
            ),
            DataCell(Text("GET")),
            DataCell(Text("example.com")),
            DataCell(Text("/index.html")),
            DataCell(Text("text/html")),
            DataCell(Text("15 KB")),
            DataCell(Text("15 KB")),
            DataCell(Text("120 ms")),
          ],
        ),
        DataRow(
          cells: [
            DataCell(
              StatusCodeChip(statusCode: 404),
            ),
            DataCell(Text("GET")),
            DataCell(Text("example.com")),
            DataCell(Text("/missing.png")),
            DataCell(Text("image/png")),
            DataCell(Text("0 KB")),
            DataCell(Text("0 KB")),
            DataCell(Text("50 ms")),
          ],
        ),
        DataRow(
          cells: [
            DataCell(
              StatusCodeChip(statusCode: 304),
            ),
            DataCell(Text("GET")),
            DataCell(Text("example.com")),
            DataCell(Text("/style.css")),
            DataCell(Text("text/css")),
            DataCell(Text("1.5 KB")),
            DataCell(Text("0 KB")),
            DataCell(Text("80 ms")),
          ],
        ),
        DataRow(
          cells: [
            DataCell(
              StatusCodeChip(statusCode: 200),
            ),
            DataCell(Text("POST")),
            DataCell(Text("example.com")),
            DataCell(Text("/api/data")),
            DataCell(Text("application/json")),
            DataCell(Text("5 KB")),
            DataCell(Text("5 KB")),
            DataCell(Text("150 ms")),
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
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
