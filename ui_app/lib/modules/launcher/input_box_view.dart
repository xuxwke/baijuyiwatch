import 'package:bjy/utils/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'dart:developer' as developer;

import 'package:extended_text_field/extended_text_field.dart';

import 'package:bjy/controllers/input_box_controller.dart';

// GetView 是 Get 框架的套路，相当于注入了 QueryBoxController 类型作为 controller
// 但是 controller 的实例需要在 main 初始化的时候先注册
class BjyInputBoxView extends GetView<InputBoxController> {
  const BjyInputBoxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Focus(
            // 键盘事件会传到这里 除非 FocusNode.hasFocus == false
            onKeyEvent: (FocusNode node, KeyEvent event) {
              developer.log('onKeyEvent ${event.toString()}');

              if (event.logicalKey == LogicalKeyboardKey.escape &&
                  event is KeyUpEvent) {
                controller.hideWindow();
                return KeyEventResult.handled;
              }

              if (event.logicalKey == LogicalKeyboardKey.enter) {
                if (event is KeyRepeatEvent || event is KeyUpEvent) {
                  debugPrint("enter 事件");
                  if (controller.inputBoxTextFieldController.text.isEmpty) {
                    return KeyEventResult.handled;
                  }

                  // 计时中 或者 输入框编辑中
                  controller.flopTimer();
                  // 如果开始计时，窗口隐藏
                  if (controller.isTimerRunning.value) {
                    controller.hideWindow();
                  }
                  return KeyEventResult.handled;
                }
                return KeyEventResult.handled;
              }

              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  controller.historySelectMove(-1);
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  controller.historySelectMove(1);
                  return KeyEventResult.handled;
                }
              }

              // developer.log('onKeyEvent node', name: node.toStringDeep());
              return KeyEventResult.ignored;
            },
            child: Column(
              children: [
                // 输入框
                Stack(
                  children: [
                    SizedBox(
                      height: controller.inputSizeBoxHeight.value,
                      child: Theme(
                        data: ThemeData(
                          textSelectionTheme: TextSelectionThemeData(),
                        ),
                        // child: Container(),
                        child: Material(
                          child: ExtendedTextField(
                            style: TextStyle(
                              fontSize: 28.0,
                              color: defaultTheme.inputBoxTextColor,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                left: 8,
                                right: 68,
                                top: 4,
                                bottom: 17,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: defaultTheme.inputBoxBgColor,
                              hoverColor: Colors.transparent,
                            ),
                            // 需要从 controller 获取 focusNode, 否则会有 backspace 无效问题
                            // 该字段不设置也暂时没看出问题
                            focusNode: controller.inputBoxFocusNode,
                            controller: controller.inputBoxTextFieldController,
                            enableIMEPersonalizedLearning: true,
                          ),
                        ),
                      ),
                    ),
                    if (controller.inputBoxNotEmpty.value)
                      Positioned(
                        top: 12,
                        right: 45,
                        child: controller.isTimerRunning.value
                            ? TextButton(
                                onPressed: () {
                                  controller.flopTimer();
                                },
                                child: Text(
                                  '停止',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: defaultTheme.inputBoxButtonTextColor,
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: () {
                                  controller.flopTimer();
                                },
                                child: Text(
                                  '开始',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: defaultTheme.inputBoxButtonTextColor,
                                  ),
                                ),
                              ),
                      ),
                    if (controller.isTimerRunning.value)
                      Positioned(
                        top: 20,
                        right: 100,
                        child: Text(
                          '耗时 ${formatDuration(controller.secondTime.value)}    ',
                          style: TextStyle(
                            fontSize: 18,
                            color: defaultTheme.historyItemTextColor,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
