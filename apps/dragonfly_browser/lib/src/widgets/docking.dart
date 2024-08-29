import 'package:dragonfly/src/screens/developer_tools/developer_tools_screen.dart';
import 'package:dragonfly/src/screens/favorites/favorite_bar.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:dragonfly/src/screens/scaffold/browser_scaffold.dart';
import 'package:dragonfly/src/screens/scaffold/widgets/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget getWidgetFromRedockableInterface(
    RedockableInterface e, bool isInsideColumn) {
  return switch (e) {
    RedockableInterface.devtools => const DeveloperToolsScreen(),
    RedockableInterface.tabBar => BrowserTabBar(isInsideColumn),
    RedockableInterface.searchBar => const BrowserActionBar(),
    RedockableInterface.bookmarks => const FavoriteTabBar(),
  };
}

class DockingArea extends StatefulWidget {
  const DockingArea(
      {super.key, required this.isInsideColumn, required this.dock});

  final bool isInsideColumn;
  final Dock dock;

  @override
  State<DockingArea> createState() => _DockingAreaState();
}

class _DockingAreaState extends State<DockingArea> {
  RedockableInterface? _possibleInterface;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserInterfaceCubit, BrowserInterfaceState>(
      builder: (context, state) => Visibility(
        visible: state.currentRedockingDock != null,
        child: DragTarget<RedockableInterface>(
          onAcceptWithDetails: (details) {
            context
                .read<BrowserInterfaceCubit>()
                .addToDock(widget.dock, details.data);
            setState(() {
              _possibleInterface = null;
            });
          },
          onMove: (details) {
            setState(() {
              _possibleInterface = details.data;
            });
          },
          onLeave: (data) {
            setState(() {
              _possibleInterface = null;
            });
          },
          builder: (context, candidateData, rejectedData) =>
              switch (_possibleInterface) {
            null => Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade600.withOpacity(0.4),
                  border: Border.all(
                    width: 4,
                    color: Colors.blue.shade600,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            _ => getWidgetFromRedockableInterface(
                _possibleInterface!, widget.isInsideColumn),
          },
        ),
      ),
    );
  }
}

class RedockableWidget extends StatelessWidget {
  final RedockableInterface interface;
  final int position;
  final Widget child;

  const RedockableWidget({
    super.key,
    required this.child,
    required this.position,
    required this.interface,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<RedockableInterface>(
      data: interface,
      feedback: Material(
        color: Colors.transparent,
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blueAccent.withOpacity(0.7),
          child: const Icon(
            Icons.drag_handle,
            color: Colors.white,
          ),
        ),
      ),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {
        context.read<BrowserInterfaceCubit>().startToRedockInterface(interface);
      },
      onDraggableCanceled: (velocity, offset) {
        context.read<BrowserInterfaceCubit>().endToRedockInterface();
      },
      onDragEnd: (details) {
        context.read<BrowserInterfaceCubit>().endToRedockInterface();
      },
      onDragCompleted: () {
        context.read<BrowserInterfaceCubit>().endToRedockInterface();
      },
      child: child,
    );
  }
}
