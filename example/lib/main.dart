import 'dart:async';

import 'package:example/detail.dart';
import 'package:example/utils/sp_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:flutter_mana_kits/flutter_mana_kits.dart';

import 'utils/dio_client.dart';
import 'utils/log_generator.dart';

void main() async {
  ManaPluginManager.instance
    ..register(ManaGrid())
    ..register(ManaLicense())
    ..register(ManaPackageInfo())
    ..register(ManaMemoryInfo())
    ..register(ManaShowCode())
    ..register(ManaLogViewer())
    ..register(ManaDeviceInfo())
    ..register(ManaColorSucker())
    ..register(ManaDioInspector())
    ..register(ManaWidgetInfoInspector())
    ..register(ManaFpsMonitor())
    ..register(ManaSharedPreferencesViewer())
    ..register(ManaAlignRuler());

  runApp(ManaWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent)),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.title = 'Mana Example'});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  Future<void> sendRequest() async {
    await DioClient().randomRequest();
  }

  void addLog() {
    LogGenerator.generateRandomLog();
  }

  Future<void> addSharedPreferences() async {
    await SpClient.insertRandom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              CustomButton(
                text: 'Detail Page',
                backgroundColor: Colors.orange,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailPage()));
                },
              ),
              CustomButton(text: 'Toggle Orientation', backgroundColor: Colors.blue, onPressed: toggleOrientation),
              CustomButton(text: 'Send Request', backgroundColor: Colors.red, onPressed: sendRequest),
              CustomButton(text: 'Add Log', backgroundColor: Colors.cyan, onPressed: addLog),
              CustomButton(
                text: 'Add SharedPreferences',
                backgroundColor: Colors.deepPurple,
                onPressed: addSharedPreferences,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatefulWidget {
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final FutureOr<void> Function()? onPressed;

  const CustomButton({
    super.key,
    required this.text,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.onPressed,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading || widget.onPressed == null) return;

    setState(() => _isLoading = true);

    try {
      final result = widget.onPressed!();
      if (result is Future) {
        await result;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      style: ElevatedButton.styleFrom(backgroundColor: widget.backgroundColor, foregroundColor: widget.foregroundColor),
      child: Text(widget.text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}
