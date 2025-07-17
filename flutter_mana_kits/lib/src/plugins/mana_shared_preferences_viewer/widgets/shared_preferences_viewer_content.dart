import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';
import 'model_detail.dart';
import 'model_tile.dart';

class SharedPreferencesViewerContent extends StatefulWidget {
  const SharedPreferencesViewerContent({super.key});

  @override
  State<SharedPreferencesViewerContent> createState() => _SharedPreferencesViewerContentState();
}

class _SharedPreferencesViewerContentState extends State<SharedPreferencesViewerContent> {
  final TextEditingController _filterController = TextEditingController();
  Timer? _debounceTimer;

  final ScrollController _scrollController = ScrollController();

  List<Model> _data = [];

  /// 当前需要编辑和查看的Model
  Model? _model;

  /// 是否启用过滤
  bool _filter = false;

  /// 过滤关键字词
  String _filterKeywords = '';

  // 统一的字体大小
  static const double _fontSize = 12.0;
  // 分割线颜色
  static final Color _dividerColor = Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    _filterController.addListener(_onTextChanged);
    _loadPrefs();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList();

    keys.sort();

    final List<Model> data = [];
    for (final (index, key) in keys.indexed) {
      final value = prefs.get(key);
      if (value != null) {
        var kind = value.runtimeType.toString();

        if (kind.startsWith('List<')) {
          kind = 'List<String>';
        }

        data.add(Model(index, key, value.toString(), kind));
      }
    }
    setState(() => _data = data);
  }

  // 复制文本并显示提示的方法
  void _copy(Model m) async {
    final String textToCopy = m.key;

    await Clipboard.setData(ClipboardData(text: textToCopy));
  }

  Future<void> _save(Model oldModel, Model newModel) async {
    final prefs = await SharedPreferences.getInstance();
    if (oldModel.key.isNotEmpty) {
      await prefs.remove(oldModel.key);
    }
    switch (newModel.kind.toLowerCase()) {
      case 'double':
        await prefs.setDouble(newModel.key, double.parse(newModel.value));
        break;
      case 'bool':
        await prefs.setBool(newModel.key, newModel.value == 'true');
        break;
      case 'int':
        await prefs.setInt(newModel.key, int.parse(newModel.value));
        break;
      case 'string':
        await prefs.setString(newModel.key, newModel.value);
        break;
      default:
        final decoded = jsonDecode(newModel.value);
        await prefs.setStringList(newModel.key, decoded as List<String>);
        break;
    }
    await _loadPrefs();
    setState(() {
      _model = null;
    });
  }

  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadPrefs();
  }

  Future<void> _removeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await _loadPrefs();
  }

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _filterKeywords = _filterController.text;
      });
    });
  }

  /// 开关过滤
  void _toggleFilter() {
    setState(() {
      _filter = !_filter;
    });
  }

  /// 创建中部区域
  Widget _buildCenter() {
    final filterData = _filter && _filterKeywords.isNotEmpty
        ? _data.where((value) {
            return value.key.contains(_filterKeywords);
          }).toList()
        : _data;

    return Expanded(
      child: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            itemCount: filterData.length,
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              final model = filterData[index];
              return ModelTile(
                key: ValueKey(model.key),
                model: model,
                onTap: () {
                  setState(() {
                    _model = model;
                  });
                },
                onCopy: () {
                  _copy(model);
                },
                onDelete: () {
                  _removeKey(model.key);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                height: 1,
                color: Colors.grey[200],
              );
            },
          ),
          if (_model != null)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: ModelDetail(
                model: _model!,
                onClose: () {
                  setState(() {
                    _model = null;
                  });
                },
                onSave: (newModel) async {
                  await _save(_model!, newModel);
                },
              ),
            )
        ],
      ),
    );
  }

  /// 创建底部操作栏
  Widget _buildBottom() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          if (_filter) ...[
            TextField(
              controller: _filterController,
              style: const TextStyle(fontSize: _fontSize),
              decoration: InputDecoration(
                hintText: 'filter keywords...',
                hintStyle: TextStyle(fontSize: _fontSize, color: Colors.black54),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            Divider(height: 1, color: _dividerColor),
          ],
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double buttonWidth = constraints.maxWidth / 4;

              return ToggleButtons(
                isSelected: [false, false, false, false],
                renderBorder: false,
                constraints: BoxConstraints(minHeight: 36.0, minWidth: buttonWidth),
                textStyle: const TextStyle(fontSize: _fontSize),
                onPressed: (int index) {
                  switch (index) {
                    case 0:
                      _clearAll();
                      return;
                    case 1:
                      setState(() {
                        _model = Model(0, '', '', 'string');
                      });
                      return;
                    case 2:
                      _loadPrefs();
                      return;
                    case 3:
                      _toggleFilter();
                      return;
                  }
                },
                children: [
                  Center(child: Text('Clear')),
                  Center(child: Text('Add')),
                  Center(child: Text('Refresh')),
                  Center(child: Text(_filter ? 'Filter(on)' : 'Filter(off)')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: _dividerColor),
        _buildCenter(),
        if (_model == null) ...[
          Divider(height: 1, color: _dividerColor),
          _buildBottom(),
        ],
      ],
    );
  }
}
