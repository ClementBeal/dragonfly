import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:dragonfly/src/screens/scaffold/widgets/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              (_possibleInterface != null)
                  ? BrowserTabBar(widget.isInsideColumn)
                  : Container(
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
        ),
      ),
    );
  }
}

class RedockableWidget extends StatefulWidget {
  final RedockableInterface interface;
  final Widget child;

  const RedockableWidget({
    super.key,
    required this.child,
    required this.interface,
  });

  @override
  State<RedockableWidget> createState() => _RedockableWidgetState();
}

class _RedockableWidgetState extends State<RedockableWidget> {
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<RedockableInterface>(
      data: widget.interface,
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
        context
            .read<BrowserInterfaceCubit>()
            .startToRedockInterface(widget.interface);
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
      child: widget.child,
    );
  }
}
