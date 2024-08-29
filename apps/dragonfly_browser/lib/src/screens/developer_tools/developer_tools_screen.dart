import 'package:dragonfly/src/screens/developer_tools/tools/network/network_tool_screen.dart';
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
            width: 200,
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
                      GestureDetector(
                        onLongPress: () {
                          context
                              .read<BrowserInterfaceCubit>()
                              .startToRedockInterface(
                                RedockableInterface.devtools, // TO DO : fix
                              );
                        },
                        onLongPressUp: () {
                          context
                              .read<BrowserInterfaceCubit>()
                              .endToRedockInterface();
                        },
                        child: const Icon(
                          Icons.pan_tool_alt,
                          // color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconWithTool(
                        icon: Icons.sync_alt_outlined,
                        label: "Network",
                        isSelected: selectedTool == DeveloperTool.network,
                      ),
                    ],
                  ),
                ),
                const Expanded(child: NetworkToolScreen()),
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
