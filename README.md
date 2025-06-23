# Flutter Mana

[![pub package](https://img.shields.io/pub/v/flutter_mana.svg)](https://pub.dev/packages/flutter_mana)

Flutter 应用内调试工具平台.

> 因为flutter_ume不维护，项目因此而生

## 使用

- 安装

```shell
flutter pub add flutter_mana
```

- 代码中使用

```dart
import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

void main() {
  if (kDebugMode) {
    ManaPluginManager.instance
      ..register(ManaLogger())
      ..register(ManaDeviceInfo())
      ..register(ManaColorSucker())
      ..register(ManaDio())
      ..register(ManaAlignRuler());
    
    runApp(ManaWidget(child: MyApp(), enable: true));
  } else {
    runApp(MyApp());
  }
}
```

## 内置插件

- [x] [标尺 - AlignRuler](https://github.com/lhlyu/flutter_mana/tree/master/lib/src/plugins/mana_align_ruler)
- [x] [日志查看器 - Logger](https://github.com/lhlyu/flutter_mana/tree/master/lib/src/plugins/mana_logger)
- [x] [设备信息 - DeviceInfo](https://github.com/lhlyu/flutter_mana/tree/master/lib/src/plugins/mana_device_info)
- [x] [颜色吸管 - ColorSucker](https://github.com/lhlyu/flutter_mana/tree/master/lib/src/plugins/mana_color_sucker)
- [x] [Dio网络检查器 - DioInspector](https://github.com/lhlyu/flutter_mana/tree/master/lib/src/plugins/mana_dio)

| 插件   | 预览                                                                                                                        | 插件       | 预览                                                                                                                   | 插件   | 预览                                                                                                                       |
|------|---------------------------------------------------------------------------------------------------------------------------|----------|----------------------------------------------------------------------------------------------------------------------|------|--------------------------------------------------------------------------------------------------------------------------|
| 标尺   | <img src="https://github.com/lhlyu/flutter_mana/blob/master/screenshots/mana_align_ruler.jpg" alt="标尺" width="33.33%">    | 日志查看器    | <img src="https://github.com/lhlyu/flutter_mana/blob/master/screenshots/mana_logger.jpg" alt="日志查看器" width="33.33%"> | 设备信息 | <img src="https://github.com/lhlyu/flutter_mana/blob/master/screenshots/mana_device_info.jpg" alt="设备信息" width="33.33%"> |
| 颜色吸管 | <img src="https://github.com/lhlyu/flutter_mana/blob/master/screenshots/mana_color_sucker.jpg" alt="颜色吸管" width="33.33%"> | Dio网络检查器 | <img src="https://github.com/lhlyu/flutter_mana/blob/master/screenshots/mana_dio.jpg" alt="Dio网络检查器" width="33.33%"> |      |                                                                                                                          |

## 插件开发

- [参考](https://github.com/lhlyu/flutter_mana/tree/master/lib/src/plugins/demo)

- 安装依赖

```shell
flutter pub add flutter_mana
```

- 实现接口

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

/// png to base64
const _iconData =
    r'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';

final _iconBytes = base64Decode(_iconData);

final iconImage = MemoryImage(_iconBytes);

/// 自定义接口
class Demo extends ManaPluggable {
  final String customName;

  Demo({this.customName = 'mana_demo'});

  @override
  Widget? buildWidget(BuildContext? context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Center(child: Text('当前的插件是: $customName')),
    );
  }

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '例子_$customName';
      default:
        return 'Demo_$customName';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => customName;

  @override
  void onTrigger() {}
}
```

- 注册接口使用

```dart
void main() {
  ManaPluginManager.instance.register(Demo());

  runApp(const ManaWidget(child: MyApp()));
}
```

## 第三方依赖

| 名字               | 作用   | 最新版本                                                                                                           |
|------------------|------|----------------------------------------------------------------------------------------------------------------|
| logger           | 日志记录 | [![pub package](https://img.shields.io/pub/v/logger.svg)](https://pub.dev/packages/logger)                     |
| device_info_plus | 设备信息 | [![pub package](https://img.shields.io/pub/v/device_info_plus.svg)](https://pub.dev/packages/device_info_plus) |
| dio              | 网络请求 | [![pub package](https://img.shields.io/pub/v/dio.svg)](https://pub.dev/packages/dio)                           |

## 工具

- [PNG图片转Base64](https://base64.guru/converter/encode/image/png)

## 参考

- [flutter_ume](https://github.com/bytedance/flutter_ume)
- [inspector](https://github.com/kekland/inspector)
- [logarte](https://github.com/kamranbekirovyz/logarte)
- [plus_plugins](https://github.com/fluttercommunity/plus_plugins)
- [free api](https://jsonplaceholder.typicode.com/)
- [info_popup](https://pub.dev/packages/info_popup)
