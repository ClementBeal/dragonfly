import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/pages/file_explorer_page.dart';
import 'package:dragonfly/src/screens/developer_tools/tools/network/widgets/request_datatable.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkToolScreen extends StatelessWidget {
  const NetworkToolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          height: 40,
          child: ContentRequestSelectionBar(),
        ),
        Expanded(
          child: NetworkRequestDataTable(),
        ),
        NetworkRequestDataRow(),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<BrowserCubit>().cleanNetworkTool();
            },
            child: Icon(Icons.delete),
          ),
          SizedBox(width: 12),
          Expanded(
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
          ),
        ],
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

class NetworkRequestDataRow extends StatelessWidget {
  const NetworkRequestDataRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserCubit, Browser>(
      builder: (context, state) {
        final tracker = state.currentTab?.tracker;

        if (tracker == null || tracker.history.isEmpty) {
          return const Row();
        }

        final firstRequest = tracker.history.first;
        final finishIn = (firstRequest.response == null)
            ? Duration.zero
            : firstRequest.response!.timestamp
                .difference(firstRequest.timestamp);
        final totalDownloadedUncompressed = tracker.history.fold(
          0,
          (previousValue, element) =>
              previousValue +
              (element.response?.contentLengthUncompressed ?? 0),
        );
        final totalDownloadedCompressed = tracker.history.fold(
          0,
          (previousValue, element) =>
              previousValue + (element.response?.contentLengthCompressed ?? 0),
        );

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
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text("${tracker.history.length} request(s)"),
                  VerticalDivider(),
                  Text(
                      "${formatBytes(totalDownloadedCompressed, decimals: 0)} / ${formatBytes(totalDownloadedUncompressed, decimals: 0)} transfered"),
                  VerticalDivider(),
                  Text("Finish : ${finishIn.inMilliseconds}ms"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
