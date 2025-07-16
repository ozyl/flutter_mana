import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';

/// `ServiceWrapper` 类封装了与 Dart VM 服务交互的各种操作。
/// 它提供了一系列方法来获取 VM 信息、内存使用情况、类列表、快照等。
class ServiceWrapper {
  vm.VmService? _service; // VM 服务实例，用于与 Dart VM 进行通信
  String? _isolateId; // 当前协程（Isolate）的 ID

  /// 构造函数，在创建实例时初始化 Isolate ID。
  /// 这样可以确保 Isolate ID 在后续方法调用之前可用。
  ServiceWrapper() {
    _isolateId = Service.getIsolateId(Isolate.current);
  }

  /// 获取当前协程的 ID。
  /// 此值在构造函数中已初始化。
  String get isolateId {
    // 确保 isolateId 不为空，如果为空则抛出状态错误，表示初始化问题。
    if (_isolateId == null) {
      throw StateError('Isolate ID has not been initialized.');
    }
    return _isolateId!;
  }

  /// 获取 VM 服务实例。
  /// 如果 [_service] 为空，则尝试建立与 VM 服务的连接并返回实例。
  /// 包含错误处理，以应对连接失败的情况。
  Future<vm.VmService> getVMService() async {
    if (_service != null) {
      return _service!;
    }
    try {
      // 获取服务协议信息，其中包含 VM 服务的 URI
      ServiceProtocolInfo info = await Service.getInfo();
      String url = info.serverUri.toString();
      Uri uri = Uri.parse(url);
      // 将服务协议 URI 转换为 WebSocket URL
      Uri socketUri = convertToWebSocketUrl(serviceProtocolUrl: uri);
      // 连接到 VM 服务
      _service = await vmServiceConnectUri(socketUri.toString());
      debugPrint('Successfully connected to VM Service at: $socketUri');
      return _service!;
    } catch (e) {
      debugPrint('Failed to connect to VM Service: $e');
      rethrow; // 重新抛出异常，以便调用方可以处理
    }
  }

  /// 断开与 VM 服务的连接。
  /// 可以在应用程序关闭或不再需要服务时调用。
  Future<void> disconnect() async {
    if (_service != null) {
      try {
        await _service!.dispose();
        _service = null;
        debugPrint('Disconnected from VM Service.');
      } catch (e) {
        debugPrint('Error during VM Service disconnection: $e');
      }
    }
  }

  /// 获取 Dart VM 的信息。
  Future<vm.VM> getVM() async {
    vm.VmService virtualMachine = await getVMService();
    return virtualMachine.getVM();
  }

  /// 获取当前协程的内存使用情况。
  Future<vm.MemoryUsage> getMemoryUsage() async {
    vm.VmService virtualMachine = await getVMService();
    return virtualMachine.getMemoryUsage(isolateId); // 使用非空断言，因为 isolateId 已在构造函数中初始化
  }

  /// 获取当前协程中所有已加载类的列表。
  Future<vm.ClassList> getClassList() async {
    vm.VmService virtualMachine = await getVMService();
    return virtualMachine.getClassList(isolateId);
  }

  /// 获取当前协程的内存分配概要信息，并重置统计数据。
  /// 允许通过参数控制是否重置统计数据。
  Future<vm.AllocationProfile> getAllocationProfile({bool reset = true}) async {
    vm.VmService virtualMachine = await getVMService();
    return virtualMachine.getAllocationProfile(isolateId, reset: reset);
  }

  /// 获取当前协程的详细信息。
  Future<vm.Isolate> getIsolate() async {
    vm.VmService virtualMachine = await getVMService();
    return virtualMachine.getIsolate(isolateId);
  }

  /// 获取当前协程中所有已加载库的引用列表。
  Future<List<vm.LibraryRef>?> getLibraries() async {
    vm.Isolate isolate = await getIsolate();
    return isolate.libraries;
  }

  /// 获取当前协程的堆快照图。
  Future<vm.HeapSnapshotGraph> getSnapshot() async {
    vm.VmService virtualMachine = await getVMService();
    vm.Isolate isolate = await getIsolate();
    return vm.HeapSnapshotGraph.getSnapshot(virtualMachine, isolate);
  }

  /// 获取指定对象 ID 的实例集合。
  /// [objectId]：对象的 ID。
  /// [limit]：返回实例的最大数量。
  /// 添加了错误处理以捕获 API 调用失败的情况。
  Future<vm.InstanceSet> getInstances(String objectId, int limit) async {
    vm.VmService virtualMachine = await getVMService();
    try {
      return virtualMachine.getInstances(isolateId, objectId, limit);
    } catch (e) {
      debugPrint('Error getting instances for $objectId: $e');
      rethrow;
    }
  }

  /// 获取当前协程的调用栈信息。
  Future<vm.Stack> getStack() async {
    vm.VmService virtualMachine = await getVMService();
    return virtualMachine.getStack(isolateId);
  }

  /// 获取指定对象 ID 的详细信息。
  /// [objectId]：对象的 ID。
  /// [offset]：如果对象是列表或字符串，表示开始获取的偏移量。
  /// [count]：如果对象是列表或字符串，表示获取的元素或字符数量。
  Future<vm.Obj> getObject(String objectId, {int? offset, int? count}) async {
    vm.VmService virtualMachine = await getVMService();
    return virtualMachine.getObject(isolateId, objectId, offset: offset, count: count);
  }

  /// 获取指向指定对象的入站引用。
  /// [objectId]：对象的 ID。
  /// [limit]：返回入站引用的最大数量，默认为 100。
  Future<vm.InboundReferences> getInboundReferences(String objectId, {int limit = 100}) async {
    vm.VmService virtualMachine = await getVMService();
    return virtualMachine.getInboundReferences(isolateId, objectId, limit);
  }

  /// 获取所有类的堆统计信息，只返回当前字节数或实例数大于 0 的类。
  /// 可以通过可选参数 [minBytes] 和 [minInstances] 来调整过滤条件。
  Future<List<vm.ClassHeapStats>> getClassHeapStats({int minBytes = 0, int minInstances = 0}) async {
    vm.AllocationProfile profile = await getAllocationProfile(); // 获取最新的分配概要
    List<vm.ClassHeapStats> list = profile.members!
        .where((element) => element.bytesCurrent! > minBytes || element.instancesCurrent! > minInstances)
        .toList();
    return list;
  }

  /// 获取当前协程中所有已加载脚本的列表。
  Future<vm.ScriptList> getScripts() async {
    vm.VmService virtualMachine = await getVMService();
    return virtualMachine.getScripts(isolateId);
  }

  /// 在指定目标上评估一个表达式。
  /// [targetId]：目标对象的 ID，通常是库或类。
  /// [expression]：要评估的 Dart 表达式字符串。
  /// 添加了错误处理以捕获评估失败的情况。
  Future<vm.Response> evaluate(String targetId, String expression) async {
    vm.VmService virtualMachine = await getVMService();
    try {
      return virtualMachine.evaluate(isolateId, targetId, expression);
    } catch (e) {
      debugPrint('Error evaluating expression "$expression" on $targetId: $e');
      rethrow;
    }
  }
}
