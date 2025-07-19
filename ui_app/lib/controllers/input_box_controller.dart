import 'package:bjy/utils/windows/window_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'package:bjy/models/timer_record.dart';

typedef KeyUpCallback = void Function();

class InputBoxController extends GetxController {
  // final 的原因是 obs 对象不可变，但是对象里面的属性值可以变
  final count = 0.obs;
  final secondTime = 0.obs;
  final inputBoxNotEmpty = false.obs; // 添加 observable 变量
  final inputBoxTextFieldController = TextEditingController();
  final inputBoxFocusNode = FocusNode();

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
    });

    // 定时器的回调
    _stopWatchTimer.secondTime.listen((value) {
      secondTime.value = value;
    });

    // 热键
    // 全局热键的套路代码
    WidgetsFlutterBinding.ensureInitialized();
    // ctrl+[
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          inputBoxFocusNode.requestFocus();
        });
        resizeWindow();
      },
    );
    // await hotKeyManager.unregisterAll();

    // debug
    timeRecordList.add(
      TimerRecord(name: "a", seconds: 1, startTime: 111, endTime: 222),
    );
    timeRecordList.add(
      TimerRecord(name: "b", seconds: 2, startTime: 111, endTime: 222),
    );
    timeRecordList.add(
      TimerRecord(name: "c", seconds: 3, startTime: 111, endTime: 222),
    );

    historyListIdx.value = -1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inputBoxFocusNode.requestFocus();
    });

    // 设置初始窗口大小
    resizeWindow();
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
    // 如果计时器正在运行，不考虑历史记录
    if (!isTimerRunning.value) {
      h += timeRecordList.length * timeRecordSizeBoxHeight.toDouble();
    }
    windowManager.setSize(Size(_width, h));
  }

  historySelectMove(int step) {
    // 如果输入框在编辑状态
    if (inputBoxFocusNode.hasFocus) {
      debugPrint('historySelectMove 输入框聚焦中');
      if (step > 0) {
        // 向下移动无效
        return;
      } else if (step < 0) {
        // 向上移动丢失聚焦; 选中最后一条历史记录
        inputBoxFocusNode.unfocus();
        historyListIdx.value = timeRecordList.length - 1;
        return;
      }
    }

    if ((historyListIdx.value == (timeRecordList.length - 1)) && (step > 0)) {
      debugPrint("列表底部再往下选择 是输入框");
      // 列表底部再往下选择 是输入框
      historyListIdx.value = -1;
      inputBoxFocusNode.requestFocus();

      return;
    }
    if ((historyListIdx.value <= 0) && (step < 0)) {
      return;
    }

    historyListIdx.value += step;
  }

  reuseHistoryTimer() {
    if ((historyListIdx.value < 0) ||
        (historyListIdx.value >= timeRecordList.length)) {
      return;
    }

    String name = timeRecordList[historyListIdx.value].name;
    _startTimer(name);
    // 输入框填充
    inputBoxTextFieldController.text = name;
    // 更新窗口大小
    resizeWindow();
  }
}
