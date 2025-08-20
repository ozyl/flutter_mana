import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mana_kits/flutter_mana_kits.dart';
import 'package:flutter_mana_kits/src/i18n/i18n_mixin.dart';
import 'package:flutter_mana_kits/src/icons/kit_icons.dart';
import 'package:flutter_mana_kits/src/plugins/mana_storage_viewer/storage/storage_scope.dart';

import 'model.dart';
import 'model_detail.dart';
import 'model_tile.dart';

class StorageViewerContent extends StatefulWidget {
  const StorageViewerContent({super.key});

  @override
  State<StorageViewerContent> createState() => _StorageViewerContentState();
}

class _StorageViewerContentState extends State<StorageViewerContent>
    with I18nMixin, SingleTickerProviderStateMixin {
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

  static final _divider = Divider(height: 1, color: Colors.grey.shade200);

  final List<StorageProvider> _storageProviders = [];

  StorageProvider? get _storageProvider =>
      _storageProviders.elementAtOrNull(_tabController?.index ?? 0);

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storageProviders
          .addAll(StorageScope.of(context)?.storageProviders ?? []);
      _loadData();
      _tabController =
          TabController(length: _storageProviders.length, vsync: this)
            ..addListener(() {
              if (!_tabController!.indexIsChanging) {
                _loadData();
              }
          });
    });
    _filterController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final keys = await _storageProvider?.getAllKeys() ?? [];
      keys.sort();

      final List<Model> data = [];
      for (final (index, key) in keys.indexed) {
        final value = await _storageProvider?.getValue(key);
        if (value != null) {
          var kind = value.runtimeType.toString();

          if (kind.startsWith('List<')) {
            kind = 'List<String>';
          }

          var v = value.toString();
          if (kind == 'List<String>') {
            v = jsonEncode(value);
          }

          data.add(Model(index, key, v, kind));
        }
      }
      setState(() => _data = data);
    } catch (e) {
      // 处理错误，显示错误信息
      debugPrint('Error loading data: $e');
    }
  }

  // 复制文本并显示提示的方法
  void _copy(Model m) async {
    final String textToCopy = m.key;

    await Clipboard.setData(ClipboardData(text: textToCopy));
  }

  Future<void> _save(Model oldModel, Model newModel) async {
    try {
      if (oldModel.key.isNotEmpty) {
        await _storageProvider?.removeKey(oldModel.key);
      }

      dynamic value;
      switch (newModel.kind.toLowerCase()) {
        case 'double':
          value = double.parse(newModel.value);
          break;
        case 'bool':
          value = newModel.value == 'true';
          break;
        case 'int':
          value = int.parse(newModel.value);
          break;
        case 'string':
          value = newModel.value;
          break;
        default:
          value = jsonDecode(newModel.value) as List<dynamic>;
          break;
      }

      await _storageProvider?.setValue(newModel.key, value);
      await _loadData();
      setState(() {
        _model = null;
      });
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> _clearAll() async {
    try {
      await _storageProvider?.clear();
      await _loadData();
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  Future<void> _removeKey(String key) async {
    try {
      await _storageProvider?.removeKey(key);
      await _loadData();
    } catch (e) {
      debugPrint('Error removing key: $e');
    }
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _filterKeywords = _filterController.text);
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
      child: ListView.separated(
        controller: _scrollController,
        itemCount: filterData.length,
        physics: const ClampingScrollPhysics(),
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
                hintText: t('storage_viewer.filter_keywords'),
                hintStyle:
                    TextStyle(fontSize: _fontSize, color: Colors.black54),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            _divider,
          ],
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const selects = [false, false, false, false];

              double buttonWidth = constraints.maxWidth / selects.length;

              return ToggleButtons(
                isSelected: selects,
                renderBorder: false,
                constraints:
                    BoxConstraints(minHeight: 36.0, minWidth: buttonWidth),
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
                      _loadData();
                      return;
                    case 3:
                      _toggleFilter();
                      return;
                  }
                },
                children: [
                  Icon(
                    KitIcons.clear,
                    size: 16,
                  ),
                  Icon(
                    KitIcons.add,
                    size: 16,
                  ),
                  Icon(
                    KitIcons.refresh,
                    size: 16,
                  ),
                  Icon(
                    _filter ? KitIcons.filter_off : KitIcons.filter_on,
                    size: 16,
                  ),
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
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              _divider,
              if(_tabController!=null && _storageProviders.length>1)TabBar(
                  controller: _tabController,
                  tabs:
                      _storageProviders.map((e) => Tab(text: e.name)).toList()),
              _buildCenter(),
              _divider,
              _buildBottom(),
            ],
          ),
        ),
        if (_model != null)
          Positioned.fill(
            child: Container(
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
            ),
          )
      ],
    );
  }
}
