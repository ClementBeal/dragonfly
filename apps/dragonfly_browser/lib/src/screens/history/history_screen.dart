import 'package:flutter/material.dart';

void showHistoryScreen(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => HistoryScreen(),
  );
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 1200,
        height: 800,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 20, // Replace with actual history length
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(
                  'Website Title ${index + 1}'), // Replace with actual title
              subtitle:
                  Text('example.com/${index + 1}'), // Replace with actual URL
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  // TODO: Implement history deletion logic
                },
              ),
              onTap: () {
                // TODO: Implement navigation to history item
              },
            );
          },
        ),
      ),
    );
  }
}
