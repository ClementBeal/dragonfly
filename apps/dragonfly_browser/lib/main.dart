import 'package:dragonfly/config/themes.dart';
import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly/src/screens/browser/blocs/render_screen_cubit.dart';
import 'package:dragonfly/src/screens/browser/pages/cubit/file_explorer_cubit.dart';
import 'package:dragonfly/src/screens/scaffold/browser_scaffold.dart';
import 'package:dragonfly/src/screens/lobby/cubit/browser_interface_cubit.dart';
import 'package:dragonfly/src/screens/settings/cubit/settings_cubit.dart';
import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:window_manager/window_manager.dart';

late final Highlighter htmlHighlighter;
late final Highlighter cssHightlighter;
late final BrowserFavorites browserFavorites;
late final NavigationHistory navigationHistory;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbManager = DatabaseManager();
  final db = dbManager.initialize(".");

  navigationHistory = NavigationHistory(db);

  await windowManager.ensureInitialized();
  Highlighter.initialize(
    [
      '../../../assets/languages/html',
      '../../../assets/languages/css',
    ],
  );

  var lightTheme = await HighlighterTheme.loadLightTheme();

  cssHightlighter = Highlighter(
    language: '../../../assets/languages/css',
    theme: lightTheme,
  );
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
        BlocProvider(
          create: (context) => BrowserCubit(
            Browser(
              navigationHistory,
            ),
          ),
        ),
        BlocProvider(create: (context) => FileExplorerCubit()),
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => BrowserInterfaceCubit()),
        BlocProvider(create: (context) => RenderScreenCubit()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.themeMode != current.themeMode ||
            previous.mainColor != current.mainColor,
        builder: (context, state) => MaterialApp(
          title: "Dragonfly",
          debugShowCheckedModeBanner: false,
          theme: getLightTheme(state.mainColor),
          darkTheme: getDarkTheme(state.mainColor),
          themeMode: state.themeMode,
          home: const LobbyScreen(),
        ),
      ),
    );
  }
}
