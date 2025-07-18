// memory_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_mana_kits/src/i18n/i18n_mixin.dart';

import '../utils/memory_service.dart';

/// 显示特定类的详细信息，包括属性和函数。
class MemoryDetail extends StatefulWidget {
  final FormattedClassHeapStats detail;

  /// 内存服务实例。
  final MemoryService service;

  /// 构造函数。
  const MemoryDetail({
    super.key,
    required this.detail,
    required this.service,
  });

  @override
  State<MemoryDetail> createState() => _MemoryDetailState();
}

class _MemoryDetailState extends State<MemoryDetail> with I18nMixin {
  /// 类的属性信息字符串。
  String _propertiesInfo = "";

  /// 类的函数信息字符串。
  String _functionsInfo = "";

  @override
  void initState() {
    super.initState();
    _fetchClassDetails();
  }

  /// 从 MemoryService 获取类的详细信息。
  Future<void> _fetchClassDetails() async {
    widget.service.getClassDetailInfo(widget.detail.classRef?.id ?? '', (info) {
      if (info != null) {
        // 构建属性信息字符串。
        final propertiesBuffer = StringBuffer();
        for (final prop in info.properties) {
          propertiesBuffer.writeln(prop.propertyStr);
        }
        _propertiesInfo = propertiesBuffer.toString();

        // 构建函数信息字符串。
        final functionsBuffer = StringBuffer();
        for (final func in info.functions) {
          functionsBuffer.writeln(func);
        }
        _functionsInfo = functionsBuffer.toString();
      } else {
        _propertiesInfo = '';
        _functionsInfo = '';
      }
      setState(() {
        // 更新UI显示详情。
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: AppBar(
          elevation: 0.0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.white,
          title: Text(widget.detail.classRef?.name ?? 'N/A'),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        child: _propertiesInfo.isEmpty && _functionsInfo.isEmpty
            ? Center(
                child: Text(
                  t('memory_info.class_no_detail'),
                  style: TextStyle(fontSize: 20),
                ),
              )
            : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        t('memory_info.location'),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      widget.detail.classRef?.location?.script?.uri ?? 'N/A',
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        t('memory_info.property'),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      _propertiesInfo,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        t('memory_info.function'),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      _functionsInfo,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
