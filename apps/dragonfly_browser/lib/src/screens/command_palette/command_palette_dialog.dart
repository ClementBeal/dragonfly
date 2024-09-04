import 'package:dragonfly/src/screens/command_palette/palette_commands.dart';
import 'package:flutter/material.dart';

Future<void> showCommandPalette(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => const CommandPaletteDialog(),
  );
}

class CommandPaletteDialog extends StatelessWidget {
  const CommandPaletteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: SizedBox(
          width: 600,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 32,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final command = paletteCommands[index];

                        return ListTile(
                          title: Text(command.title),
                          titleTextStyle: TextStyle(
                            fontSize: 22,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            command.onSelected(context);
                          },
                        );
                      },
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: paletteCommands.length),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
