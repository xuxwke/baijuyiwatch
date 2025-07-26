import 'dart:io' show Platform; // 只在非Web平台引入
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'package:bjy/models/timer_record.dart';
import 'package:bjy/utils/windows/window_manager.dart';

typedef KeyUpCallback = void Function();

class InputBoxController extends GetxController {
  // final 的原因是 obs 对象不可变，但是对象里面的属性值可以变
  final count = 0.obs;
  final secondTime = 0.obs;
  final inputBoxNotEmpty = false.obs; // 添加 observable 变量
  final inputBoxTextFieldController = TextEditingController();
  final inputBoxFocusNode = FocusNode();
  int _lastTextLength = 0;

  final double _width = 480;
  final inputSizeBoxHeight = 55.0.obs;
  final timeRecordSizeBoxHeight = 40.0.obs;

  // historyList
  final historyListIdx = (-1).obs;

  // 计时器
  // _ 下划线开头意味着 private
  final _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);
  final isTimerRunning = false.obs;

  // 历史的记录
  final timeRecordList = <TimerRecord>[].obs;
  var _curTimeRecord = TimerRecord.empty();

  @override
  void onInit() async {
    super.onInit();
    // 监听文本变化
    inputBoxTextFieldController.addListener(() {
      inputBoxNotEmpty.value = inputBoxTextFieldController.text.isNotEmpty;

      // 记录最新的长度
      _lastTextLength = inputBoxTextFieldController.text.length;
    });

    // 定时器的回调
    _stopWatchTimer.secondTime.listen((value) {
      secondTime.value = value;
    });

    // 热键
    // 全局热键的套路代码
    WidgetsFlutterBinding.ensureInitialized();
    // ctrl+[
    var modfiers = [HotKeyModifier.control];
    if (Platform.isMacOS) {
      modfiers = [HotKeyModifier.meta];
    }

    HotKey hotKey = HotKey(
      key: PhysicalKeyboardKey.bracketLeft,
      modifiers: modfiers,
      scope: HotKeyScope.system,
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) async {
        debugPrint('热键: ${hotKey.toJson()}');
        await windowManager.show();
        // 对于 linux 平台, show 是不够的,
        // await windowManager.center(400, 400);
        await windowManager.focus();
        // 输入框申请 focus
        // 使用回调的原因是 窗口刚刚出现 request 不一定能被窗口服务器正确处理

        resizeWindow();
      },
    );
    // await hotKeyManager.unregisterAll();

    // debug
    timeRecordList.add(
      TimerRecord(name: "吃水果", seconds: 1, startTime: 111, endTime: 222),
    );
    timeRecordList.add(
      TimerRecord(name: "看视频", seconds: 22, startTime: 111, endTime: 222),
    );
    timeRecordList.add(
      TimerRecord(name: "收拾桌面", seconds: 90, startTime: 111, endTime: 222),
    );

    historyListIdx.value = timeRecordList.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("请求焦点");
      inputBoxFocusNode.requestFocus();
    });

    // 设置初始窗口大小
    resizeWindow();

    // 等待窗口准备好
    await windowManager.waitUntilReadyToShow();
    await windowManager.show();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  // 方法
  increment() => count.value++;

  _startTimer(String name) {
    // 开始计时
    _stopWatchTimer.onStartTimer();
    isTimerRunning.value = true;

    // 记录一个 model
    _curTimeRecord = TimerRecord(
      name: name,
      seconds: 0,
      startTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      endTime: 0,
    );
  }

  startTimer() {
    _startTimer(inputBoxTextFieldController.text);
  }

  stopTimer() {
    // 保存记录
    _curTimeRecord.endTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _curTimeRecord.seconds = secondTime.value;
    timeRecordList.add(_curTimeRecord);
    _curTimeRecord = TimerRecord.empty();

    // 最多保存五个
    if (timeRecordList.length > 5) {
      timeRecordList.value = timeRecordList.sublist(1);
    }
    debugPrint(
      'timeRecordList: ${timeRecordList.map((ele) => ele.toString())}',
    );

    // 停止计时器
    _stopWatchTimer.onStopTimer();
    _stopWatchTimer.onResetTimer();
    isTimerRunning.value = false;

    // 清空 input
    inputBoxTextFieldController.clear();

    historyResetMove();
  }

  flopTimer() {
    if (_stopWatchTimer.isRunning) {
      stopTimer();
    } else {
      startTimer();
    }
    // 更新窗口大小
    resizeWindow();
  }

  hideWindow() {
    windowManager.hide();
  }

  showWindow() {
    windowManager.show();
  }

  resizeWindow() {
    debugPrint("resizeWindow");
    double h = inputSizeBoxHeight.value;
    // h += 20;
    // 如果计时器正在运行，不考虑历史记录
    if (!isTimerRunning.value) {
      h += timeRecordList.length * timeRecordSizeBoxHeight.toDouble();
    }
    windowManager.setSize(Size(_width, h));
  }

  historyResetMove() {
    historyListIdx.value = timeRecordList.length;
  }

  historySelectMove(int step) {
    if ((historyListIdx.value >= (timeRecordList.length - 1)) && (step > 0)) {
      debugPrint("列表已到底部");
      historyResetMove();
      return;
    }
    if ((historyListIdx.value <= 0) && (step < 0)) {
      debugPrint("列表已到顶部");
      return;
    }

    historyListIdx.value += step;
    String name = timeRecordList[historyListIdx.value].name;
    // 输入框填充
    inputBoxTextFieldController.text = name;
  }
}
