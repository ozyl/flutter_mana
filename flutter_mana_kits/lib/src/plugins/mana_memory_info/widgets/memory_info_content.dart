import 'package:flutter/material.dart';
import 'package:flutter_mana_kits/src/i18n/i18n_mixin.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/memory_service.dart';
import 'memory_detail.dart';

class MemoryInfoContent extends StatefulWidget {
  const MemoryInfoContent({super.key});

  @override
  State<MemoryInfoContent> createState() => _MemoryInfoContentState();
}

class _MemoryInfoContentState extends State<MemoryInfoContent> with I18nMixin {
  final MemoryService _memoryService = MemoryService();

  String _pkg = '';

  // 当前的排序字段和排序方向
  String _currentSortField = 'accumulatedSize'; // 默认按大小排序
  bool _isAscending = false;

  /// 控制是否隐藏私有类的复选框状态。
  bool _hidePrivateClasses = true;

  /// 是否只展示当前项目的
  bool _onlyCurrentPackage = false;

  @override
  void initState() {
    super.initState();

    // 初始加载数据
    _memoryService.getInfos(() {
      _sortClassHeapStats(); // 初始数据加载后进行排序
      setState(() {}); // 数据加载完成后刷新UI
    });

    PackageInfo.fromPlatform().then((info) {
      final packageName = info.packageName;

      _pkg = 'package:${packageName.split('.').last}/';
    });
  }

  /// 根据当前排序字段和方向对 classHeapStatsList 进行排序。
  void _sortClassHeapStats() {
    switch (_currentSortField) {
      case 'accumulatedSize':
        _memoryService.sortClassHeapStats(
          (stats) => stats.accumulatedSize ?? 0,
          !_isAscending, // accumulatedSize 默认降序，所以升序时需要反转
          () => setState(() {}),
        );
        break;
      case 'instancesCurrent':
        _memoryService.sortClassHeapStats(
          (stats) => stats.instancesCurrent ?? 0,
          !_isAscending, // instancesCurrent 默认降序
          () => setState(() {}),
        );
        break;
      case 'className':
        _memoryService.sortClassHeapStats(
          (stats) => stats.classRef?.name ?? '',
          _isAscending, // 类名默认升序
          () => setState(() {}),
        );
        break;
      default:
        break;
    }
  }

  /// 构建排序图标。
  Widget _buildSortIcon(String fieldName) {
    IconData icon;
    if (_currentSortField == fieldName) {
      icon = _isAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down;
    } else {
      icon = Icons.unfold_more; // 未排序的默认图标
    }
    return Icon(icon, size: 16);
  }

  Widget _buildTableHeaderCol({int flex = 1, required String field, required String label}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_currentSortField == field) {
              _isAscending = !_isAscending;
            } else {
              _currentSortField = field;
              _isAscending = false; // 默认降序
            }
            _sortClassHeapStats();
          });
        },
        child: Row(
          children: [
            Text(t(label), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildSortIcon(field),
          ],
        ),
      ),
    );
  }

  /// 构建表格行。
  Widget _buildTableRow(String label, String value, {TextStyle? style}) {
    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: style ?? TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Expanded(child: SelectableText(value, style: style ?? TextStyle(fontSize: 14))),
      ],
    );
  }

  /// 进入类详情页面。
  void _navigateToDetailPage(FormattedClassHeapStats detail) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return MemoryDetail(detail: detail, service: _memoryService);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmInfo = _memoryService.vmInfo;
    final memoryInfo = _memoryService.memoryUsageInfo;
    final classHeapStatsList = _memoryService.classHeapStatsList;

    var items = _hidePrivateClasses
        ? classHeapStatsList.where((v) => !(v.classRef?.name?.startsWith('_') ?? false)).toList()
        : classHeapStatsList;

    items = _onlyCurrentPackage && _pkg.isNotEmpty
        ? items.where((v) => (v.classRef?.location?.script?.uri?.contains(_pkg) ?? false)).toList()
        : items;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          // VM 和内存信息的 SliverAppBar
          SliverAppBar(
            toolbarHeight: 0,
            expandedHeight: 400.0,
            floating: false,
            pinned: true,
            forceElevated: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              background: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Text(
                      t('memory_info.vm_info'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        _buildTableRow('PID:', '${vmInfo?.pid ?? 'N/A'}'),
                        _buildTableRow('CPU:', vmInfo?.hostCPU ?? 'N/A'),
                        _buildTableRow(t('memory_info.version'), vmInfo?.version ?? 'N/A'),
                      ],
                    ),
                    Text(
                      t('memory_info.memory_info'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        _buildTableRow('Heap Usage:',
                            '${memoryInfo?.heapUsageFormatted ?? 'N/A'} / ${memoryInfo?.heapCapacityFormatted ?? 'N/A'}'),
                        _buildTableRow('External Usage:', memoryInfo?.externalUsageFormatted ?? 'N/A'),
                      ],
                    ),
                    Column(
                      spacing: 4,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                value: _hidePrivateClasses,
                                onChanged: (value) {
                                  setState(() {
                                    _hidePrivateClasses = !_hidePrivateClasses;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(t('memory_info.hide_private_classes')),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                materialTapTargetSize: MaterialTapTargetSize.padded,
                                value: _onlyCurrentPackage,
                                onChanged: (value) {
                                  setState(() {
                                    _onlyCurrentPackage = !_onlyCurrentPackage;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text('当前项目'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildTableRow('总数:', '${items.length}'),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(39),
              child: Container(
                color: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  children: [
                    _buildTableHeaderCol(field: 'accumulatedSize', label: 'memory_info.size'),
                    _buildTableHeaderCol(field: 'instancesCurrent', label: 'memory_info.number'),
                    _buildTableHeaderCol(flex: 3, field: 'className', label: 'memory_info.class_name'),
                  ],
                ),
              ),
            ),
          ),

          // 类堆统计信息的 ListView
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                final bool isEven = index % 2 == 1;
                return InkWell(
                  onTap: () {
                    _navigateToDetailPage(item);
                  },
                  child: Container(
                    color: isEven ? Colors.grey.shade100 : Colors.white, // 交替背景色
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(item.accumulatedSizeFormatted),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('${item.instancesCurrent ?? 'N/A'}'),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.classRef?.name ?? 'Unknown Class',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}
