import 'package:example/sp_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'dio_client.dart';
import 'log_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ManaPluginManager.instance
    ..register(ManaLogger())
    ..register(ManaDeviceInfo())
    ..register(ManaColorSucker())
    ..register(ManaDio())
    ..register(ManaWidgetInfoInspector())
    ..register(ManaFpsMonitor())
    ..register(ManaSharedPreferencesViewer())
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
      home: MyHomePage(title: 'Mana Example'),
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

  @override
  void initState() {
    super.initState();
  }

  void sendRequest() async {
    await DioClient().randomRequest();
  }

  void addLog() {
    LogGenerator.generateRandomLog();
  }

  void addSharedPreferences() async {
    await SpClient.insertRandom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: toggleOrientation,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text('Toggle Orientation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: sendRequest,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Send Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: addLog,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, foregroundColor: Colors.white),
              child: const Text('Add Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: addSharedPreferences,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
              child: const Text('Add SharedPreferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
