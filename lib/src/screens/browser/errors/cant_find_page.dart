import 'package:dragonfly/browser/page.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerNotFoundPage extends StatelessWidget {
  const ServerNotFoundPage({super.key, required this.tab, required this.tabId});

  final ErrorResponse tab;
  final int tabId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'The server is taking a break or is unavailable right now. Please check your internet connection or try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                context.read<BrowserCubit>().retry(tabId);
              }, // Add your retry logic here
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
