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
      children: [
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
