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
          return Center(
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
                    child: Text("JSON"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        buttonData = [false, true];
                      });
                    },
                    child: Text("Raw Data"),
                  ),
                ],
              ),
            ),
            Expanded(
                child: (buttonData[0])
                    ? Container()
                    : _RawJsonScreen(
                        jsonObject: data,
                      )),
          ],
        );
      },
    );
  }
}

class _RawJsonScreen extends StatelessWidget {
  const _RawJsonScreen({super.key, required this.jsonObject});

  final Object jsonObject;

  @override
  Widget build(BuildContext context) {
    final json = JsonEncoder.withIndent("   ").convert(jsonObject);

    return SingleChildScrollView(child: Text(json));
  }
}
