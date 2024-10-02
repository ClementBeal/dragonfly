import 'package:dragonfly/src/screens/browser/browser_screen.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InspectorLayout extends StatelessWidget {
  const InspectorLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BoxModelPanel();
  }
}

class BoxModelPanel extends StatelessWidget {
  const BoxModelPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        BoxModelLayout(
          commonStyle: CommonStyle(
            backgroundColor: null,
            paddingTop: 2,
            paddingRight: 2,
            paddingBottom: 2,
            paddingLeft: 2,
            marginTop: 8,
            marginRight: 8,
            marginBottom: 8,
            marginLeft: 8,
            borderWidth: null,
            borderLeftColor: null,
            borderRightColor: null,
            borderTopColor: null,
            borderBottomColor: null,
            borderLeftWidth: 4,
            borderRightWidth: 4,
            borderTopWidth: 4,
            borderBottomWidth: 4,
            borderRadius: null,
            maxWidth: 1234,
            maxHeight: 320,
            minWidth: null,
            minHeight: null,
            isCentered: null,
            cursor: null,
          ),
        ),
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
    required this.commonStyle,
  });

  final CommonStyle commonStyle;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      child: IdontKnow(
        color: CommonStyleBlock.marginColor,
        leftValue: '8',
        bottomValue: '4',
        topValue: '4',
        rightValue: '8',
        child: IdontKnow(
          color: Colors.black87,
          leftValue: '2',
          bottomValue: '2',
          topValue: '2',
          rightValue: '2',
          child: IdontKnow(
            color: CommonStyleBlock.paddingColor,
            leftValue: '8',
            bottomValue: '4',
            topValue: '4',
            rightValue: '8',
            child: IdontKnow(
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
