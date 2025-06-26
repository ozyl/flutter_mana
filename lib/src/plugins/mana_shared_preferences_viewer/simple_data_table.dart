import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'expandable_selectable_text.dart';
import 'model.dart';

/// 简洁表格组件，支持固定表头 + 内容滚动 + 复制文本
class SimpleDataTable extends StatelessWidget {
  final List<Model> data;

  final ValueChanged<String>? onDeleteKey;

  const SimpleDataTable({
    super.key,
    required this.data,
    this.onDeleteKey,
  });

  List<DataColumn> _buildHeaders() {
    return const [
      DataColumn(label: Text('序号'), columnWidth: IntrinsicColumnWidth()),
      DataColumn(label: Text('Key'), columnWidth: IntrinsicColumnWidth()),
      DataColumn(label: Text('Value'), columnWidth: IntrinsicColumnWidth()),
      DataColumn(label: Text('Type'), columnWidth: IntrinsicColumnWidth()),
      DataColumn(label: Text('操作'), columnWidth: IntrinsicColumnWidth()),
    ];
  }

  List<DataRow> _buildRows() {
    return data.asMap().entries.map((d) {
      final index = d.key;
      final row = d.value;

      return DataRow(
        cells: [
          DataCell(Text('${index + 1}')),
          DataCell(ExpandableSelectableText(text: row.key)),
          DataCell(ExpandableSelectableText(text: row.value)),
          DataCell(ExpandableSelectableText(text: row.kind)),
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CheckIconButton(
                  initialIcon: Icons.copy,
                  size: 16,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '${row.key}\n\n${row.value}'));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 18),
                  onPressed: () {
                    onDeleteKey?.call(row.key);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          border: TableBorder.all(
            color: Colors.grey.shade300,
          ),
          headingRowColor: WidgetStatePropertyAll(Colors.grey.shade200),
          columns: _buildHeaders(),
          rows: _buildRows(),
        ),
      ),
    );
  }
}
