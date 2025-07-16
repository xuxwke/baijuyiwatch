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
          Focus(
            // 键盘事件会传到这里 除非 FocusNode.hasFocus == false
            onKeyEvent: (FocusNode node, KeyEvent event) {
              //   developer.log('onKeyEvent', name: event.toString());

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
                developer.log('onKeyEvent not down');
                return KeyEventResult.ignored;
              }

              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                controller.historySelectMove(-1);
                return KeyEventResult.handled;
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                controller.historySelectMove(1);
                return KeyEventResult.handled;
              }

              // developer.log('onKeyEvent node', name: node.toStringDeep());
              return KeyEventResult.ignored;
            },
            child: Column(
              children: [
                // 历史记录
                // if (controller.timeRecordList.isNotEmpty)
                ConstrainedBox(
                  key: ValueKey('container-${controller.historyListIdx.value}'),
                  constraints: BoxConstraints(maxHeight: 300, minHeight: 0),
                  child: Obx(
                    () => ListView.builder(
                      // shrink 控制 ListView 不会无脑填充外层的 box
                      shrinkWrap: true,
                      itemCount: controller.timeRecordList.length,
                      itemBuilder: (context, index) {
                        print(
                          'index: $index, historyListIdx: ${controller.historyListIdx.value}',
                        );
                        var item = controller.timeRecordList[index];
                        var color = index == controller.historyListIdx.value
                            ? Colors.greenAccent
                            : Colors.amberAccent;
                        return SizedBox(
                          key: ValueKey(
                            'item-$index-${controller.historyListIdx.value}',
                          ),
                          height: controller.timeRecordSizeBoxHeight.value,
                          child: Container(
                            decoration: BoxDecoration(color: color),
                            child: Row(
                              children: [
                                Text(
                                  '任务:${item.name}, 耗时:${item.seconds}s',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
              ],
            ),
          ),
        ],
      );
    });
  }
}
