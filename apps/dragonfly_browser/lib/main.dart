import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/lobby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:window_manager/window_manager.dart';

late final Highlighter htmlHighlighter;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  Highlighter.initialize(['../../../assets/languages/html']);

  var lightTheme = await HighlighterTheme.loadLightTheme();
  htmlHighlighter = Highlighter(
    language: '../../../assets/languages/html',
    theme: lightTheme,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BrowserCubit()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LobbyScreen(),
      ),
    );
  }
}