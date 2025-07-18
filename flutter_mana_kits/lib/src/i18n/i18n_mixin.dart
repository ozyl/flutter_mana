import 'package:flutter_mana/flutter_mana.dart';

mixin I18nMixin {
  static const _strings = {
    // Align Ruler
    'align_ruler.tip': ['Snap to nearest widget edge on release', '开启后松手将会自动吸附至最近部件边缘'],

    // Color Sucker
    'color_sucker.magnification': ['Magnification', '放大率'],

    // Dio Inspector
    'dio_inspector.filter_keywords': ['filter keywords...', '筛选字词...'],
    'dio_inspector.clear': ['Clear', '清理'],
    'dio_inspector.top': ['Top', '顶部'],
    'dio_inspector.bottom': ['Bottom', '底部'],
    'dio_inspector.filter_on': ['Filter(on)', '筛选(开)'],
    'dio_inspector.filter_off': ['Filter(off)', '筛选(关)'],
    'dio_inspector.detail': ['Detail', '详情'],
    'dio_inspector.request': ['Request', '请求'],
    'dio_inspector.response': ['Response', '响应'],
    'dio_inspector.request_details': ['Request Details', '请求详情'],
    'dio_inspector.request_header': ['Request Header', '请求头'],
    'dio_inspector.request_body': ['Request Body', '请求体'],
    'dio_inspector.response_header': ['Response Header', '响应头'],
    'dio_inspector.response_body': ['Response Body', '响应体'],

    // Fps Monitor
    'fps_monitor.tip': ['Web is not supported!', 'Web端不支持！'],

    // Log Viewer
    'log_viewer.filter_keywords': ['filter keywords...', '筛选字词...'],
    'log_viewer.clear': ['Clear', '清理'],
    'log_viewer.top': ['Top', '顶部'],
    'log_viewer.bottom': ['Bottom', '底部'],
    'log_viewer.filter_on': ['Filter(on)', '筛选(开)'],
    'log_viewer.filter_off': ['Filter(off)', '筛选(关)'],

    // Memory Info
    'memory_info.vm_info': ['VM Info', 'VM 信息'],
    'memory_info.version': ['Version:', '版本:'],
    'memory_info.memory_info': ['Memory Info', '内存信息'],
    'memory_info.hide_private_classes': ['hide private classes', '隐藏私有类'],
    'memory_info.size': ['Size', '大小'],
    'memory_info.number': ['Number', '数量'],
    'memory_info.class_name': ['Class', '类名'],
    'memory_info.class_no_detail': [
      'The object is a Sentinel or lacks detailed information',
      '该对象是一个 Sentinel 或没有详细信息'
    ],
    'memory_info.property': ['Property:', '属性:'],
    'memory_info.function': ['Function:', '方法:'],

    // Shared Preferences Viewer
    'shared_preferences_viewer.filter_keywords': ['filter keywords...', '筛选字词...'],
    'shared_preferences_viewer.clear': ['Clear', '清理'],
    'shared_preferences_viewer.add': ['Add', '新增'],
    'shared_preferences_viewer.refresh': ['Refresh', '刷新'],
    'shared_preferences_viewer.filter_on': ['Filter(on)', '筛选(开)'],
    'shared_preferences_viewer.filter_off': ['Filter(off)', '筛选(关)'],
    'shared_preferences_viewer.type': ['Type', '类型'],
    'shared_preferences_viewer.key': ['Key', '键'],
    'shared_preferences_viewer.key_required': ['Key Required', '键必填'],
    'shared_preferences_viewer.value': ['Value', '值'],
    'shared_preferences_viewer.value_required': ['Value Required', '值必填'],
    'shared_preferences_viewer.value_must_double': ['Value Must Double', '值必须是Double类型'],
    'shared_preferences_viewer.value_must_bool': ['Value Must Bool', '值必须是Bool类型'],
    'shared_preferences_viewer.value_must_int': ['Value Must Int', '值必须是Int类型'],
    'shared_preferences_viewer.value_must_list_of_string': ['Value Must List<String>', '值必须是List<String>类型'],
    'shared_preferences_viewer.save': ['Save', '保存'],
    'shared_preferences_viewer.cancel': ['Cancel', '取消'],

    // Widget Info Inspector
    'widget_info_inspector.tip': ['Switch drawing mode', '切换绘制模式'],
  };

  static final _language = manaLocale.languageCode;

  String t(String k, [String defaultValue = '']) {
    final ss = _strings[k];
    if (ss == null) {
      return defaultValue;
    }
    switch (_language) {
      case 'zh':
        return ss[1];
      default:
        return ss[0];
    }
  }
}
