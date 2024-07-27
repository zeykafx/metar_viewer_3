import 'dart:io';

import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart' as Cup;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:metar_viewer_3/screens/settings/settings_page.dart';
import 'package:metar_viewer_3/screens/settings/settings_store.dart';
import 'package:metar_viewer_3/screens/taf/taf_page.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/metar/metar_page.dart';

Database? database;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  openDb();
  Animate.restartOnHotReload = true;

  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

Future<void> openDb() async {
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  String databasesPath = await getDatabasesPath();
  String dbPath = join(databasesPath, "scxp.db");
  bool exists = await databaseExists(dbPath);

  if (!exists) {
    print("creating new copy from assets");
    try {
      await Directory(dirname(dbPath)).create(recursive: true);
    } catch (_) {}

    // list all files in the assets directory
    // print("listing assets");
    // Directory directory = Directory("assets");
    // List<FileSystemEntity> files = directory.listSync();
    // print(files);
    // print(files.last.statSync());

    // Copy from asset
    ByteData data;
    if (Platform.isWindows) {
      data = await rootBundle.load(join("assets/", "scxp.db"));
    } else {
      data = await rootBundle.load(join("assets", "scxp.db"));
    }

    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(dbPath).writeAsBytes(bytes, flush: true);
  }

  if (Platform.isWindows) {
    if (kDebugMode) {
      print("opening database with ffi");
    }
    database = await databaseFactoryFfi.openDatabase(dbPath);
  } else {
    if (kDebugMode) {
      print("opening database");
    }
    database = await openDatabase(dbPath);
  }
}

ColorScheme? lightColorScheme;
ColorScheme? darkColorScheme;

ThemeData lightTheme(ColorScheme? lightColorScheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    colorSchemeSeed: lightColorScheme == null ? Colors.orange : null,
    brightness: Brightness.light,
  );
}

ThemeData darkTheme(ColorScheme? darkColorScheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    colorSchemeSeed: darkColorScheme == null ? Colors.orange : null,
    brightness: Brightness.dark,
  );
}

class MyApp extends Cup.StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // allow access to the state from anywhere in the app, which is useful for changing the theme
  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  late LocalStorageInterface pref;
  ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    pref = await LocalStorage.getInstance();

    String darkMode = pref.getString('darkMode') ?? "System";

    themeMode = darkMode == "System"
        ? ThemeMode.system
        : darkMode == "Dark"
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  void changeThemeMode(DarkMode mode) {
    setState(() {
      themeMode = mode == DarkMode.system
          ? ThemeMode.system
          : mode == DarkMode.dark
              ? ThemeMode.dark
              : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      lightColorScheme = lightColorScheme;
      darkColorScheme = darkColorScheme;

      return MaterialApp(
        title: 'Metar Viewer',
        theme: lightTheme(lightColorScheme),
        darkTheme: darkTheme(darkColorScheme),
        themeMode: themeMode,
        home: const HomePage(),
      );
    });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  late PageController pageController;
  SettingsStore settingsStore = SettingsStore();

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    initSettingsStore();
  }

  Future<void> initSettingsStore() async {
    while (!settingsStore.initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (settingsStore.startPage) {
      if (kDebugMode) {
        print("TAF Page is the start page");
      }
      setState(() {
        currentPageIndex = 1;
        pageController.jumpToPage(currentPageIndex);
      });
    }
  }

  @override
  void dispose() {
    // pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      currentPageIndex = index;
      pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metar Viewer'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        allowImplicitScrolling: true,
        onPageChanged: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        children: const <Widget>[
          MetarPage(),
          TafPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.cloud_rounded),
            icon: Icon(Icons.cloud_outlined),
            label: 'Metar',
          ),
          NavigationDestination(
            selectedIcon: Icon(Cup.CupertinoIcons.cloud_sun_rain_fill),
            icon: Icon(Cup.CupertinoIcons.cloud_sun_rain),
            label: 'TAF',
          ),
        ],
      ),
    );
  }
}
