import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:flutter_mana/src/plugins/mana_device_info/widgets/device_info_content.dart';

class DeviceInfo extends StatelessWidget {
  final String name;

  const DeviceInfo({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: name,
      content: DeviceInfoContent(),
    );
  }
}
