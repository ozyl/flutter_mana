import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'filter_input.dart';
import 'icon.dart';
import 'model.dart';
import 'simple_data_table.dart';
import 'top_bar.dart';

class ManaSharedPreferencesViewer extends StatefulWidget implements ManaPluggable {
  const ManaSharedPreferencesViewer({super.key});

  @override
  State<ManaSharedPreferencesViewer> createState() => _ManaSharedPreferencesViewerState();

  @override
  Widget? buildWidget(BuildContext? context) => this;

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return 'Shared Preferences';
      default:
        return 'Shared Preferences';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_shared_preferences_viewer';

  @override
  void onTrigger() {}
}

class _ManaSharedPreferencesViewerState extends State<ManaSharedPreferencesViewer> {
  List<Model> _data = [];
  bool _filter = false;
  String _filterKeywords = '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final List<Model> data = [];
    for (final (index, key) in keys.indexed) {
      final value = prefs.get(key);
      if (value != null) {
        data.add(Model(index, key, value.toString(), value.runtimeType.toString()));
      }
    }
    setState(() => _data = data);
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

  void _toggleFilterVisibility() {
    setState(() {
      _filter = !_filter;
    });
  }

  void _onFilterKeywordsChanged(String keywords) {
    setState(() {
      _filterKeywords = keywords;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filterData = _filter && _filterKeywords.isNotEmpty
        ? _data.where((value) {
            return value.key.contains(_filterKeywords);
          }).toList()
        : _data;

    return ManaFloatingWindow(
      name: widget.name,
      initialWidth: double.infinity,
      position: PositionType.bottom,
      drag: false,
      showModal: false,
      header: Column(
        children: [
          Divider(height: 1, color: Colors.grey[200]),
          TopBar(
            onClear: _clearAll,
            onToggleFilter: _toggleFilterVisibility,
            onRefresh: _loadPrefs,
          ),
          if (_filter) ...[
            Divider(height: 1, color: Colors.grey[200]),
            FilterInput(
              onFilterKeywordsChanged: _onFilterKeywordsChanged,
            ),
          ],
          Divider(height: 1, color: Colors.grey[200]),
        ],
      ),
      body: SimpleDataTable(
        data: filterData,
        onDeleteKey: _removeKey,
      ),
    );
  }
}
