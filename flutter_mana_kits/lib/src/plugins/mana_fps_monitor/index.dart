import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'icon.dart';

class ManaFpsMonitor extends StatefulWidget implements ManaPluggable {
  const ManaFpsMonitor({super.key});

  @override
  State<ManaFpsMonitor> createState() => _ManaFpsMonitorState();

  @override
  Widget? buildWidget(BuildContext? context) => this;

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '帧率监控';
      default:
        return 'Fps Monitor';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_fps_monitor';

  @override
  void onTrigger() {}

  @override
  Future<void> initialize() async {}
}

class _ManaFpsMonitorState extends State<ManaFpsMonitor> {
  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: widget.name,
      initialHeight: 200,
      initialWidth: kIsWeb ? null : double.infinity,
      showBarrier: false,
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: kIsWeb
            ? Center(
                child: Text(
                  'Web is not supported!',
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              )
            : PerformanceOverlay.allEnabled(),
      ),
    );
  }
}
