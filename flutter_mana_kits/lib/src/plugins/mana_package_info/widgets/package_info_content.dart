import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoContent extends StatefulWidget {
  const PackageInfoContent({super.key});

  @override
  State<PackageInfoContent> createState() => _PackageInfoContentState();
}

class _PackageInfoContentState extends State<PackageInfoContent> {
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();

    _data = {
      'appName': info.appName,
      'packageName': info.packageName,
      'version': info.version,
      'buildNumber': info.buildNumber,
      'buildSignature': info.buildSignature,
      'installerStore': info.installerStore,
      'installTime': info.installTime,
      'updateTime': info.updateTime,
    };

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_data.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
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
