import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'log_generator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ManaPluginManager.instance
    ..register(Demo())
    ..register(ManaLogger())
    ..register(ManaAlignRuler());

  runApp(const ManaWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent)),
      home: const MyHomePage(title: 'Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLandscape = false;

  void toggleOrientation() {
    if (isLandscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
    setState(() {
      isLandscape = !isLandscape;
    });
  }

  void sendRequest() {}

  void addLog() {
    LogGenerator.generateRandomLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(color: Colors.lightBlue, borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Mana',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: toggleOrientation,
                  child: const Text(
                    'Toggle Orientation',
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: sendRequest,
                  child: const Text(
                    'Send Request',
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: addLog,
                  child: const Text(
                    'Add Log',
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
