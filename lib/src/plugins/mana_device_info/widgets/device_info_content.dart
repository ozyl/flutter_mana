import 'package:flutter/material.dart';

import '../utils/get_device_info.dart';

class DeviceInfoContent extends StatefulWidget {
  const DeviceInfoContent({super.key});

  @override
  State<DeviceInfoContent> createState() => _DeviceInfoContentState();
}

class _DeviceInfoContentState extends State<DeviceInfoContent> {
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

    return body;
  }
}
