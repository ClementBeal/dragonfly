import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DockingArea extends StatelessWidget {
  final Widget? child;

  const DockingArea({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserInterfaceCubit, BrowserInterfaceState>(
      builder: (context, state) {
        final bool isDocking = state.currentRedockingInterface != null;
        return DragTarget<RedockableInterface>(
          builder: (context, candidateData, rejectedData) => AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: (isDocking)
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: SizedBox.shrink(),
            firstChild: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDocking
                    ? Colors.blue.shade600.withOpacity(0.4)
                    : Colors.transparent,
                // borderRadius: BorderRadius.circular(30),
                border: isDocking
                    ? Border.all(
                        width: 4,
                        color: Colors.blue.shade600,
                      )
                    : null,
              ),
              child: child ??
                  Center(
                    child: Icon(
                      Icons.add,
                      color: isDocking ? Colors.white : Colors.blue.shade600,
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }
}
