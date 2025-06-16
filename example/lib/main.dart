import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ManaPluginManager.instance
    ..register(Demo())
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
      home: const MyHomePage(title: '测试'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Center(
        child: Container(
          color: Colors.lightBlue,
          width: 200,
          height: 200,
          child: Center(
            child: Text(
              '你好',
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
