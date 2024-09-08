import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConsoleScreen extends StatefulWidget {
  const ConsoleScreen({super.key});

  @override
  State<ConsoleScreen> createState() => _ConsoleScreenState();
}

class _ConsoleScreenState extends State<ConsoleScreen> {
  final List<dynamic> messages = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          itemCount: messages.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(messages[index].toString()),
          ),
        ),
        SizedBox(
          height: 40,
          child: ConsoleTextField(
            onScriptExecuted: (output) {
              messages.add(output);
              print(output);
              setState(() {});
            },
          ),
        )
      ],
    );
  }
}

class ConsoleTextField extends StatefulWidget {
  const ConsoleTextField({
    super.key,
    required this.onScriptExecuted,
  });

  final void Function(dynamic output) onScriptExecuted;

  @override
  State<ConsoleTextField> createState() => _ConsoleTextFieldState();
}

class _ConsoleTextFieldState extends State<ConsoleTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.double_arrow),
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            decoration:
                const InputDecoration.collapsed(hintText: "Type your code"),
            onSubmitted: (value) {
              _controller.clear();

              final currentTab = context.read<BrowserCubit>().state.currentTab;

              if (currentTab != null) {
                final output = currentTab.interpreter.execute(value);
                print(output);
                widget.onScriptExecuted(output);
              }
            },
          ),
        )
      ],
    );
  }
}
