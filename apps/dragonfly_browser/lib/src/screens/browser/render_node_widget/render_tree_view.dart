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
            previous.showMobileViewPort != current.showMobileViewPort ||
            previous.viewportHeight != current.viewportHeight ||
            previous.viewportWidth != current.viewportWidth,
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
                  child: ResponsiveDesignModeBar(),
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: state.viewportHeight,
                      width: state.viewportWidth,
                      child: w,
                    ),
                  ),
                ),
              ],
            );
          }
          return SizedBox.expand(
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

class ResponsiveDesignModeBar extends StatefulWidget {
  const ResponsiveDesignModeBar({super.key});

  @override
  State<ResponsiveDesignModeBar> createState() =>
      _ResponsiveDesignModeBarState();
}

class _ResponsiveDesignModeBarState extends State<ResponsiveDesignModeBar> {
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    final state =
        context.read<BrowserInterfaceCubit>().state; // Access the state
    _widthController =
        TextEditingController(text: state.viewportWidth.toStringAsFixed(0));
    _heightController =
        TextEditingController(text: state.viewportHeight.toStringAsFixed(0));
  }

  void _onSizeChanged() {
    final widthText = _widthController.text;
    final heightText = _heightController.text;

    // Check if both width and height are valid integers
    if (widthText.isNotEmpty &&
        heightText.isNotEmpty &&
        double.tryParse(widthText) != null &&
        double.tryParse(heightText) != null) {
      context
          .read<BrowserInterfaceCubit>()
          .setDeviceViewport(double.parse(widthText), double.parse(heightText));
    }
  }

  void _flipDimensions() {
    final width = double.tryParse(_widthController.text);
    final height = double.tryParse(_heightController.text);

    if (width != null && height != null) {
      _widthController.text = height.toStringAsFixed(0);
      _heightController.text = width.toStringAsFixed(0);
      _onSizeChanged(); // Notify the cubit of the change
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceDim,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                context.read<BrowserInterfaceCubit>().closeMobileViewPort(),
            child: const Icon(Icons.close, color: Colors.red),
          ),
          SizedBox(
            width: 50, // Adjust width as needed
            child: TextField(
              controller: _widthController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _onSizeChanged(),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  isDense: true),
            ),
          ),
          const Text('x'),
          SizedBox(
            width: 50,
            child: TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _onSizeChanged(),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  isDense: true),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.screen_rotation),
            onPressed: _flipDimensions,
          ),
        ],
      ),
    );
  }
}
