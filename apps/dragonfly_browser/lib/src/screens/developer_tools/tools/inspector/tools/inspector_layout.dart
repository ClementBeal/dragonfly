import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/browser_screen.dart';
import 'package:dragonfly/src/screens/developer_tools/cubit/devtols_cubit.dart';
import 'package:dragonfly/src/screens/settings/cubit/settings_cubit.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InspectorLayout extends StatelessWidget {
  const InspectorLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BoxModelPanel();
  }
}

class BoxModelPanel extends StatefulWidget {
  const BoxModelPanel({super.key});

  @override
  State<BoxModelPanel> createState() => _BoxModelPanelState();
}

class _BoxModelPanelState extends State<BoxModelPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        BoxModelLayout(),
        BoxModelProperties(),
      ],
    );
  }
}

class BoxModelProperties extends StatelessWidget {
  const BoxModelProperties({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Property(property: "box-sizing", value: "NOT IMPLEMENTED"),
        _Property(property: "display", value: "NOT IMPLEMENTED"),
        _Property(property: "float", value: "NOT IMPLEMENTED"),
        _Property(property: "line-height", value: "NOT IMPLEMENTED"),
        _Property(property: "position", value: "NOT IMPLEMENTED"),
        _Property(property: "z-index", value: "NOT IMPLEMENTED"),
      ],
    );
  }
}

class _Property extends StatelessWidget {
  const _Property({required this.property, required this.value});

  final String property;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              property,
              style: TextStyle(color: Colors.cyan),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BoxModelLayout extends StatelessWidget {
  const BoxModelLayout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      child: BlocBuilder<DevToolsCubit, DevToolsState>(
        builder: (context, state) {
          if (state.selectedDomHash == null) return SizedBox.shrink();

          final style = (context
                      .watch<BrowserCubit>()
                      .state
                      .currentTab!
                      .currentPage as HtmlPage)
                  .renderTree
                  ?.findStyle(state.selectedDomHash!) ??
              CommonStyle.empty();

          print(state.selectedDomHash);
          print(style.marginLeft);
          print(style.marginRight);
          print(style.marginTop);
          print(style.marginRight);

          return IdontKnow(
            color: CommonStyleBlock.marginColor,
            leftValue: (style.marginLeft ?? 0).toString(),
            bottomValue: (style.marginBottom ?? 0).toString(),
            topValue: (style.marginTop ?? 0).toString(),
            rightValue: (style.marginRight ?? 0).toString(),
            child: IdontKnow(
              color: Colors.black87,
              leftValue: (style.borderLeftWidth ?? 0).toString(),
              bottomValue: (style.borderBottomWidth ?? 0).toString(),
              topValue: (style.borderTopWidth ?? 0).toString(),
              rightValue: (style.borderRightWidth ?? 0).toString(),
              child: IdontKnow(
                color: CommonStyleBlock.paddingColor,
                leftValue: (style.paddingLeft ?? 0).toString(),
                bottomValue: (style.paddingBottom ?? 0).toString(),
                topValue: (style.paddingTop ?? 0).toString(),
                rightValue: (style.paddingRight ?? 0).toString(),
                child: const IdontKnow(
                  color: CommonStyleBlock.elementColor,
                  leftValue: null,
                  bottomValue: null,
                  topValue: null,
                  rightValue: null,
                  child: Text(
                    "?x?",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class IdontKnow extends StatelessWidget {
  const IdontKnow({
    super.key,
    required this.child,
    required this.color,
    this.leftValue,
    this.topValue,
    this.rightValue,
    this.bottomValue,
  });

  final Widget child;
  final Color color;
  final String? leftValue;
  final String? topValue;
  final String? rightValue;
  final String? bottomValue;

  @override
  Widget build(BuildContext context) {
    const edgeInsets = EdgeInsets.all(4.0);

    return DecoratedBox(
      decoration: BoxDecoration(color: color),
      child: Column(
        children: [
          Padding(
            padding: edgeInsets,
            child: Text(
              topValue ?? "",
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: edgeInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      leftValue ?? "",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: child,
              ),
              Padding(
                padding: edgeInsets,
                child: Column(
                    children: [if (rightValue != null) Text(rightValue!)]),
              ),
            ],
          ),
          Padding(
            padding: edgeInsets,
            child: Text(
              bottomValue ?? "",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
