import 'package:dragonfly/src/screens/command_palette/palette_commands.dart';
import 'package:flutter/material.dart';

Future<void> showCommandPalette(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => const CommandPaletteDialog(),
  );
}

class CommandPaletteDialog extends StatefulWidget {
  const CommandPaletteDialog({super.key});

  @override
  State<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<CommandPaletteDialog> {
  String filter = "";

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 700,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 32,
                    ),
                    onChanged: (value) {
                      setState(() {
                        filter = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Expanded(
                    child: Builder(builder: (context) {
                      final commandList = paletteCommands
                          .where(
                            (e) => e.title.toLowerCase().contains(filter),
                          )
                          .toList();

                      return ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final command = commandList[index];

                            return ListTile(
                              title: Text(command.title),
                              subtitle: Text(command.description),
                              titleTextStyle: const TextStyle(
                                fontSize: 22,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                command.onSelected(context);
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: commandList.length);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
