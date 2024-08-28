import 'package:dragonfly/src/screens/favorites/favorite_bar.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DeveloperTool { network }

class DeveloperToolsScreen extends StatefulWidget {
  const DeveloperToolsScreen({super.key});

  @override
  State<DeveloperToolsScreen> createState() => _DeveloperToolsScreenState();
}

class _DeveloperToolsScreenState extends State<DeveloperToolsScreen> {
  DeveloperTool selectedTool = DeveloperTool.network;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<BrowserInterfaceCubit>().closeDevTools();
                  },
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconWithTool(
                  icon: Icons.sync_alt_outlined,
                  label: "Network",
                  isSelected: selectedTool == DeveloperTool.network,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ContentRequestSelectionBar(),
          ),
        ],
      ),
    );
  }
}

class IconWithTool extends StatelessWidget {
  const IconWithTool(
      {super.key,
      required this.icon,
      required this.label,
      required this.isSelected});

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          border: Border(
        top: (isSelected)
            ? BorderSide(
                color: Colors.blue.shade800,
                width: 3,
              )
            : BorderSide.none,
      )),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(label),
        ],
      ),
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
