import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'device_info.dart';
import 'icon.dart';

class ManaDeviceInfo extends StatefulWidget implements ManaPluggable {
  const ManaDeviceInfo({super.key});

  @override
  State<ManaDeviceInfo> createState() => _ManaDeviceInfoState();

  @override
  Widget? buildWidget(BuildContext? context) => this;

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '设备信息';
      default:
        return 'Device Info';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_device_info';

  @override
  void onTrigger() {}
}

class _ManaDeviceInfoState extends State<ManaDeviceInfo> {
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  void _getDeviceInfo() async {
    _data = await getDeviceInfo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_data.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = SingleChildScrollView(
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          border: TableBorder(
            horizontalInside: BorderSide(width: 1, color: Colors.grey.shade200),
            verticalInside: BorderSide(width: 1, color: Colors.grey.shade200),
            top: BorderSide(width: 1, color: Colors.grey.shade200),
            bottom: BorderSide(width: 1, color: Colors.grey.shade200),
            // 不设置 left, right
          ),
          children: _data.entries.map((entry) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText('${entry.value}'),
                ),
              ],
            );
          }).toList(),
        ),
      );
    }
    return ManaFloatingWindow(name: widget.name, body: body);
  }
}
