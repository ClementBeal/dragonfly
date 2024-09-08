import 'package:dragonfly/src/screens/developer_tools/tools/console/console_screen.dart';
import 'package:dragonfly/src/screens/developer_tools/tools/network/network_tool_screen.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DeveloperTool { network, console }

class DeveloperToolsScreen extends StatefulWidget {
  const DeveloperToolsScreen({super.key, required this.isInsideColumn});

  final bool isInsideColumn;

  @override
  State<DeveloperToolsScreen> createState() => _DeveloperToolsScreenState();
}

class _DeveloperToolsScreenState extends State<DeveloperToolsScreen> {
  DeveloperTool selectedTool = DeveloperTool.console;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserInterfaceCubit, BrowserInterfaceState>(
      builder: (context, state) {
        if (!state.showDevtools) return const SizedBox.shrink();

        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 2,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ),
          child: SizedBox(
            width: (!widget.isInsideColumn) ? 200 : null,
            height: (widget.isInsideColumn) ? 200 : null,
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
                      const SizedBox(width: 8),
                      IconWithTool(
                        icon: Icons.computer,
                        label: "Console",
                        isSelected: selectedTool == DeveloperTool.console,
                      ),
                      IconWithTool(
                        icon: Icons.sync_alt_outlined,
                        label: "Network",
                        isSelected: selectedTool == DeveloperTool.network,
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: switch (selectedTool) {
                  DeveloperTool.network => const NetworkToolScreen(),
                  DeveloperTool.console => const ConsoleScreen(),
                }),
              ],
            ),
          ),
        );
      },
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            Text(label),
          ],
        ),
      ),
    );
  }
}
