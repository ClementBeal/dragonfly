import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/pages/cubit/file_explorer_cubit.dart';
import 'package:dragonfly/src/screens/scaffold/browser_scaffold.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dragonfly_navigation/dragonfly_navigation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:window_manager/window_manager.dart';

late final Highlighter htmlHighlighter;
late final BrowserFavorites browserFavorites;
late final NavigationHistory navigationHistory;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = initialize("test.sqlite");
  // final db = initializeInMemory();
  browserFavorites = BrowserFavorites(db);
  navigationHistory = NavigationHistory(db);

  // if (kDebugMode) {
  //   for (var i = 0; i < 2000; i++) {
  //     navigationHistory.fakeData(
  //       Uri.parse(Faker().internet.httpsUrl()),
  //       Faker().internet.domainName(),
  //       Faker().date.dateTimeBetween(DateTime(2022), DateTime.now()),
  //     );
  //   }
  // }

  await windowManager.ensureInitialized();
  Highlighter.initialize(['../../../assets/languages/html']);

  var lightTheme = await HighlighterTheme.loadLightTheme();
  htmlHighlighter = Highlighter(
    language: '../../../assets/languages/html',
    theme: lightTheme,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    loadCss();
  }

  Future<void> loadCss() async {
    try {
      final browserCSS =
          await rootBundle.loadString("assets/styles/browser_style.css");

      cssomBuilder.loadBrowserStyle(browserCSS);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BrowserCubit()),
        BlocProvider(create: (context) => FileExplorerCubit()),
        BlocProvider(create: (context) => BrowserInterfaceCubit()),
      ],
      child: MaterialApp(
        title: "Dragonfly",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.cyanAccent),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
        home: LobbyScreen(),
      ),
    );
  }
}
