import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class NetworkToolScreen extends StatelessWidget {
  const NetworkToolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ContentRequestSelectionBar(),
        ),
        Expanded(
          child: NetworkRequestDataTable(),
        ),
      ],
    );
  }
}

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
              Text(
                "200",
                style: TextStyle(color: Colors.green),
              ),
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
              Text(
                "404",
                style: TextStyle(color: Colors.red),
              ),
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
              Text(
                "304",
                style: TextStyle(color: Colors.orange),
              ),
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
              Text(
                "200",
                style: TextStyle(color: Colors.green),
              ),
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

class ContentRequestSelectionBar extends StatefulWidget {
  const ContentRequestSelectionBar({super.key});

  @override
  State<ContentRequestSelectionBar> createState() =>
      _ContentRequestSelectionBarState();
}

class _ContentRequestSelectionBarState
    extends State<ContentRequestSelectionBar> {
  final contentRequests = ["All", "HTML", "CSS"];
  List<bool> selectedContent = [true, false, false];

  void _updateSelection(int index) {
    setState(() {
      if (index == 0) {
        // If "All" is selected, deselect others
        selectedContent = [true, false, false];
      } else {
        // If any other is selected, deselect "All" and toggle the clicked item
        selectedContent[0] = false;
        selectedContent[index] = !selectedContent[index];

        // If all others are deselected, select "All"
        if (!selectedContent.contains(true)) {
          selectedContent[0] = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        itemCount: contentRequests.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => _updateSelection(index),
          child: ContentRequestSelection(
            contentType: contentRequests[index],
            isSelected: selectedContent[index],
          ),
        ),
      ),
    );
  }
}

class ContentRequestSelection extends StatelessWidget {
  const ContentRequestSelection(
      {super.key, required this.contentType, required this.isSelected});

  final String contentType;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Durations.short3,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue.shade700 : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            contentType,
            style: TextStyle(
              color: isSelected ? Colors.blue.shade700 : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
