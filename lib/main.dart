import 'package:dawg/settings/app_settings.dart';
import 'package:dawg/ui/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _settings = AppSettings();

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: _settings,
      child: MaterialApp(
        title: 'DAWG',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}
