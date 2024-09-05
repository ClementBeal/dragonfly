import 'dart:convert';
import 'dart:io';

import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter/material.dart';

class JsonScreen extends StatefulWidget {
  const JsonScreen({super.key, required this.page});

  final JsonPage page;

  @override
  State<JsonScreen> createState() => _JsonScreenState();
}

class _JsonScreenState extends State<JsonScreen> {
  late final dynamic _jsonFuture;
  List<bool> buttonData = [true, false];

  @override
  void initState() {
    super.initState();

    _jsonFuture = loadJson();
  }

  Future<dynamic> loadJson() async {
    final content = await File(widget.page.url).readAsString();
    return jsonDecode(content);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _jsonFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.data!;
        return Column(
          children: [
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        buttonData = [true, false];
                      });
                    },
                    child: const Text("JSON"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        buttonData = [false, true];
                      });
                    },
                    child: const Text("Raw Data"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: (buttonData[0])
                  ? SingleChildScrollView(
                      child: InteractiveJsonScreen(
                        jsonObject: data,
                      ),
                    )
                  : _RawJsonScreen(
                      jsonObject: data,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _RawJsonScreen extends StatelessWidget {
  const _RawJsonScreen({required this.jsonObject});

  final Object jsonObject;

  @override
  Widget build(BuildContext context) {
    final json = const JsonEncoder.withIndent("   ").convert(jsonObject);

    return SingleChildScrollView(child: Text(json));
  }
}

class InteractiveJsonScreen extends StatelessWidget {
  const InteractiveJsonScreen({required this.jsonObject, super.key});

  final Object? jsonObject;

  @override
  Widget build(BuildContext context) {
    if (jsonObject is Map<String, dynamic>) {
      return JsonObjectWidget(json: jsonObject as Map<String, dynamic>);
    } else if (jsonObject is List) {
      return JsonArrayWidget(json: jsonObject as List);
    } else {
      return switch (jsonObject) {
        num a => Text(
            "$a",
            style: const TextStyle(
              color: Colors.green,
            ),
            softWrap: true,
          ),
        bool b => Text(
            "$b",
            style: const TextStyle(
              color: Colors.yellow,
            ),
            softWrap: true,
          ),
        null => const Text(
            "null",
            style: TextStyle(
              color: Colors.grey,
            ),
            softWrap: true,
          ),
        String s => Text(
            "\"$s\"",
            style: TextStyle(
              color: Colors.purple.shade200,
            ),
            softWrap: true,
          ),
        Object o => Text(
            o.toString(),
            softWrap: true,
          ),
      };
    }
  }
}

class JsonObjectWidget extends StatefulWidget {
  const JsonObjectWidget({required this.json, super.key});

  final Map<String, dynamic> json;

  @override
  JsonObjectWidgetState createState() => JsonObjectWidgetState();
}

class JsonObjectWidgetState extends State<JsonObjectWidget> {
  late final Map<String, bool> _expandedState;

  @override
  void initState() {
    super.initState();
    _expandedState = {
      for (var key in widget.json.keys) key: true
    }; // All expanded by default
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.json.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        final isExpandable = value is Map || value is List;
        final isExpanded = _expandedState[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: isExpandable
                  ? () {
                      setState(() {
                        _expandedState[key] = !isExpanded;
                      });
                    }
                  : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isExpandable)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    )
                  else
                    const SizedBox.square(dimension: 22),
                  Text(
                    '$key:   ',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isExpandable)
                    Expanded(child: InteractiveJsonScreen(jsonObject: value)),
                ],
              ),
            ),
            if (isExpandable)
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: InteractiveJsonScreen(jsonObject: value),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class JsonArrayWidget extends StatefulWidget {
  const JsonArrayWidget({required this.json, super.key});

  final List json;

  @override
  JsonArrayWidgetState createState() => JsonArrayWidgetState();
}

class JsonArrayWidgetState extends State<JsonArrayWidget> {
  final Map<int, bool> _expandedState = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.json.length,
      itemBuilder: (context, index) {
        final value = widget.json[index];
        final isExpanded = _expandedState.putIfAbsent(index, () => true);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedState[index] = !isExpanded;
                });
              },
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.expand_less,
                  ),
                  Text(
                    '$index: ',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: InteractiveJsonScreen(jsonObject: value),
              ),
          ],
        );
      },
    );
  }
}
