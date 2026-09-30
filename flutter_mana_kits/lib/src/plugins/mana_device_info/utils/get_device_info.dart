import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

Future<Map<String, dynamic>> getDeviceInfo() async {
  var deviceData = <String, dynamic>{};

  try {
    if (kIsWeb) {
      deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
    } else {
      deviceData = switch (defaultTargetPlatform) {
        TargetPlatform.android => _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
        TargetPlatform.iOS => _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
        TargetPlatform.linux => _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
        TargetPlatform.windows => _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
        TargetPlatform.macOS => _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
        TargetPlatform.fuchsia => <String, dynamic>{'Error:': 'Fuchsia platform isn\'t supported'},
        // 标准 SDK 没有 TargetPlatform.ohos，写死这个值 one_piece 编不过。
        // 鸿蒙 SDK 多了这个枚举，落到这里再读 ohosDeviceInfo。
        _ => defaultTargetPlatform.name == 'ohos'
            ? await _readOhosDeviceInfo()
            : <String, dynamic>{
                'Error:': '${defaultTargetPlatform.name} isn\'t supported',
              },
      };
    }
  } on PlatformException {
    deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
  }

  return deviceData;
}

Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'name': _later(build, (v) => v.name),
    'supported32BitAbis': build.supported32BitAbis,
    'supported64BitAbis': build.supported64BitAbis,
    'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    'freeDiskSize': _later(build, (v) => v.freeDiskSize),
    'totalDiskSize': _later(build, (v) => v.totalDiskSize),
    'systemFeatures': build.systemFeatures,
    'serialNumber': build.serialNumber,
    'isLowRamDevice': build.isLowRamDevice,
    'physicalRamSize': _later(build, (v) => v.physicalRamSize),
    'availableRamSize': _later(build, (v) => v.availableRamSize),
  };
}

Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'systemName': data.systemName,
    'systemVersion': data.systemVersion,
    'model': data.model,
    'modelName': _later(data, (v) => v.modelName),
    'localizedModel': data.localizedModel,
    'identifierForVendor': data.identifierForVendor,
    'isPhysicalDevice': data.isPhysicalDevice,
    'isiOSAppOnMac': _later(data, (v) => v.isiOSAppOnMac),
    'freeDiskSize': _later(data, (v) => v.freeDiskSize),
    'totalDiskSize': _later(data, (v) => v.totalDiskSize),
    'physicalRamSize': _later(data, (v) => v.physicalRamSize),
    'availableRamSize': _later(data, (v) => v.availableRamSize),
    'utsname.sysname': data.utsname.sysname,
    'utsname.nodename': data.utsname.nodename,
    'utsname.release': data.utsname.release,
    'utsname.version': data.utsname.version,
    'utsname.machine': data.utsname.machine,
  };
}

Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'version': data.version,
    'id': data.id,
    'idLike': data.idLike,
    'versionCodename': data.versionCodename,
    'versionId': data.versionId,
    'prettyName': data.prettyName,
    'buildId': data.buildId,
    'variant': data.variant,
    'variantId': data.variantId,
    'machineId': data.machineId,
  };
}

Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
  return <String, dynamic>{
    'browserName': data.browserName.name,
    'appCodeName': data.appCodeName,
    'appName': data.appName,
    'appVersion': data.appVersion,
    'deviceMemory': data.deviceMemory,
    'language': data.language,
    'languages': data.languages,
    'platform': data.platform,
    'product': data.product,
    'productSub': data.productSub,
    'userAgent': data.userAgent,
    'vendor': data.vendor,
    'vendorSub': data.vendorSub,
    'hardwareConcurrency': data.hardwareConcurrency,
    'maxTouchPoints': data.maxTouchPoints,
  };
}

Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
  return <String, dynamic>{
    'computerName': data.computerName,
    'hostName': data.hostName,
    'arch': data.arch,
    'model': data.model,
    'modelName': data.modelName,
    'kernelVersion': data.kernelVersion,
    'majorVersion': data.majorVersion,
    'minorVersion': data.minorVersion,
    'patchVersion': data.patchVersion,
    'osRelease': data.osRelease,
    'activeCPUs': data.activeCPUs,
    'memorySize': data.memorySize,
    'cpuFrequency': data.cpuFrequency,
    'systemGUID': data.systemGUID,
  };
}

Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
  return <String, dynamic>{
    'numberOfCores': data.numberOfCores,
    'computerName': data.computerName,
    'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    'userName': data.userName,
    'majorVersion': data.majorVersion,
    'minorVersion': data.minorVersion,
    'buildNumber': data.buildNumber,
    'platformId': data.platformId,
    'csdVersion': data.csdVersion,
    'servicePackMajor': data.servicePackMajor,
    'servicePackMinor': data.servicePackMinor,
    'suitMask': data.suitMask,
    'productType': data.productType,
    'reserved': data.reserved,
    'buildLab': data.buildLab,
    'buildLabEx': data.buildLabEx,
    'digitalProductId': data.digitalProductId,
    'displayVersion': data.displayVersion,
    'editionId': data.editionId,
    'installDate': data.installDate,
    'productId': data.productId,
    'productName': data.productName,
    'registeredOwner': data.registeredOwner,
    'releaseId': data.releaseId,
    'deviceId': data.deviceId,
  };
}

/// device_info 11.5 才有的字段。鸿蒙钉的 11.1 没有这些 getter，缺了就空。
Object? _later(Object target, Object? Function(dynamic value) read) {
  try {
    return read(target);
  } on NoSuchMethodError {
    return null;
  }
}

Future<Map<String, dynamic>> _readOhosDeviceInfo() async {
  try {
    final info = await (deviceInfoPlugin as dynamic).ohosDeviceInfo;
    return <String, dynamic>{
      'brand': info.brand,
      'manufacture': info.manufacture,
      'marketName': info.marketName,
      'productSeries': info.productSeries,
      'productModel': info.productModel,
      'softwareModel': info.softwareModel,
      'hardwareModel': info.hardwareModel,
      'osFullName': info.osFullName,
      'displayVersion': info.displayVersion,
      'sdkApiVersion': info.sdkApiVersion,
      'majorVersion': info.majorVersion,
      'seniorVersion': info.seniorVersion,
      'featureVersion': info.featureVersion,
      'buildVersion': info.buildVersion,
      'deviceType': info.deviceType,
      'isPhysicalDevice': info.isPhysicalDevice,
    };
  } catch (e) {
    return <String, dynamic>{'Error:': '$e'};
  }
}
