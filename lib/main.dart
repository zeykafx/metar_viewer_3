import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/metar.dart';

Database? database;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  openDb();

  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
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
    print("listing assets");
    Directory directory = Directory("assets");
    List<FileSystemEntity> files = directory.listSync();
    print(files);
    print(files.last.statSync());

    // Copy from asset
    ByteData data = await rootBundle.load(join("assets/", "scxp.db"));

    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(dbPath).writeAsBytes(bytes, flush: true);
  }

  if (Platform.isWindows) {
    print("opening database with ffi");
    database = await databaseFactoryFfi.openDatabase(dbPath);
  } else {
    print("opening database");
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      lightColorScheme = lightColorScheme;
      darkColorScheme = darkColorScheme;

      return MaterialApp(
        title: 'Metar Viewer',
        theme: lightTheme(lightColorScheme),
        darkTheme: darkTheme(darkColorScheme),
        themeMode: ThemeMode.system,
        home: const HomePage(),
      );
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metar Viewer'),
      ),
      body: const MetarPage(),
    );
  }
}
