import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'dart:developer' as developer;

import 'package:extended_text_field/extended_text_field.dart';

import 'package:bjy/controllers/query_box_controller.dart';

// GetView 是 Get 框架的套路，相当于注入了 QueryBoxController 类型作为 controller
// 但是 controller 的实例需要在 main 初始化的时候先注册
class BjyQueryBoxView extends GetView<QueryBoxController> {
  const BjyQueryBoxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Positioned(
            // 键盘事件会传到这里 除非 FocusNode.hasFocus == false
            child: Focus(
              onKeyEvent: (FocusNode node, KeyEvent event) {
                // debugPrint(
                //   'key event: ${event.logicalKey} ${event.toString()}',
                // );

                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  if (event is KeyRepeatEvent || event is KeyDownEvent) {
                    debugPrint("enter 事件");
                    controller.flopTimer();
                    controller.queryBoxFocusNode.requestFocus();
                    controller.hideWindow();
                    return KeyEventResult.handled;
                  }
                }

                if (event is! KeyDownEvent) {
                  return KeyEventResult.ignored;
                }

                // developer.log('onKeyEvent node', name: node.toStringDeep());
                return KeyEventResult.ignored;
              },
              child: Stack(
                children: [
                  SizedBox(
                    height: controller.sizeBoxHeight.value,
                    child: Theme(
                      data: ThemeData(
                        textSelectionTheme: TextSelectionThemeData(),
                      ),
                      // child: Container(),
                      child: Material(
                        child: ExtendedTextField(
                          style: TextStyle(fontSize: 28.0),
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
                            hoverColor: Colors.transparent,
                          ),
                          // 需要从 controller 获取 focusNode, 否则会有 backspace 无效问题
                          // 该字段不设置也暂时没看出问题
                          focusNode: controller.queryBoxFocusNode,
                          controller: controller.queryBoxTextFieldController,
                          // scrollController: controller.queryBoxScrollController,
                          enableIMEPersonalizedLearning: true,
                        ),
                      ),
                    ),
                  ),
                  if (controller.queryBoxNotEmpty.value)
                    Positioned(
                      top: 12,
                      right: 45,
                      child: controller.isTimerRunning.value
                          ? TextButton(
                              onPressed: () {
                                controller.stopTimer();
                              },
                              child: Text('停止'),
                            )
                          : TextButton(
                              onPressed: () {
                                controller.startTimer();
                              },
                              child: Text('开始'),
                            ),
                    ),
                  if (controller.isTimerRunning.value)
                    Positioned(
                      right: 100,
                      child: Text('${controller.secondTime}s'),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
