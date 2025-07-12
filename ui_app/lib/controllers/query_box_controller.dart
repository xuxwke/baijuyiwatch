import 'package:bjy/utils/windows/window_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class QueryBoxController extends GetxController {
  // final 的原因是 obs 对象不可变，但是对象里面的属性值可以变
  final count = 0.obs;
  final secondTime = 0.obs;
  final queryBoxNotEmpty = false.obs; // 添加 observable 变量
  final queryBoxTextFieldController = TextEditingController();
  final queryBoxFocusNode = FocusNode();

  // 计时器
  // _ 下划线开头意味着 private
  final _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  final isTimerRunning = false.obs;

  @override
  void onInit() async {
    super.onInit();
    // 监听文本变化
    queryBoxTextFieldController.addListener(() {
      queryBoxNotEmpty.value = queryBoxTextFieldController.text.isNotEmpty;
    });

    // 定时器的回调
    _stopWatchTimer.secondTime.listen((value) {
      secondTime.value = value;
    });

    // 热键
    // 全局热键的套路代码
    WidgetsFlutterBinding.ensureInitialized();
    // ⌥ + Q
    HotKey hotKey = HotKey(
      key: PhysicalKeyboardKey.bracketLeft,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.system,
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) async {
        debugPrint('热键: ${hotKey.toJson()}');
        await windowManager.show();
        // 对于 linux 平台, show 是不够的,
        await windowManager.center(400, 400);
        await windowManager.focus();
        // 输入框申请 focus
        // 使用回调的原因是 窗口刚刚出现 request 不一定能被窗口服务器正确处理
        // Future.delayed(Duration(milliseconds: 100), () {
        //   queryBoxFocusNode.requestFocus();
        // });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          queryBoxFocusNode.requestFocus();
        });
      },
    );
    // await hotKeyManager.unregisterAll();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  // 方法
  increment() => count.value++;
  startTimer() {
    // 开始计时
    _stopWatchTimer.onStartTimer();
    isTimerRunning.value = true;
  }

  stopTimer() {
    _stopWatchTimer.onStopTimer();
    _stopWatchTimer.clearPresetTime();
    isTimerRunning.value = false;
  }

  flopTimer() {
    if (_stopWatchTimer.isRunning) {
      stopTimer();
    } else {
      startTimer();
    }
  }

  hideWindow() {
    windowManager.hide();
  }

  showWindow() {
    windowManager.show();
  }
}
