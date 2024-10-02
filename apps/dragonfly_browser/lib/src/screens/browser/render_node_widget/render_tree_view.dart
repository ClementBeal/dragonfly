import 'package:dragonfly/src/screens/browser/browser_screen.dart';
import 'package:dragonfly/src/screens/browser/helpers/color_utils.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserRenderTreeView extends StatelessWidget {
  const BrowserRenderTreeView({super.key, required this.r});

  final RenderTreeView r;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black87,
      child: BlocBuilder<BrowserInterfaceCubit, BrowserInterfaceState>(
        buildWhen: (previous, current) =>
            previous.showMobileViewPort != current.showMobileViewPort,
        builder: (context, state) {
          final w = DecoratedBox(
            decoration: BoxDecoration(
              color: HexColor.fromHex(r.backgroundColor),
            ),
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TreeRenderer(r.child),
                  ],
                ),
              ),
            ),
          );

          if (state.showMobileViewPort) {
            return Column(
              children: [
                SizedBox(
                  height: 40,
                  child: GestureDetector(
                    onTap: () => context
                        .read<BrowserInterfaceCubit>()
                        .closeMobileViewPort(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 800,
                    width: 400,
                    child: w,
                  ),
                ),
              ],
            );
          }
          return SizedBox.expand(
            // width: (state.showMobileViewPort) ? 400 : double.infinity,
            // height: (state.showMobileViewPort) ? 400 : double.infinity,
            child: w,
          );
        },
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
