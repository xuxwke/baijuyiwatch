import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'dart:developer' as developer;

import 'package:bjy/controllers/input_box_controller.dart';

class BjyHistoryView extends GetView<InputBoxController> {
  const BjyHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Column(
            children: [
              // 历史记录
              // 如果计时器正在计时，不展示历史记录
              if (!controller.isTimerRunning.value)
                ConstrainedBox(
                  key: ValueKey('container-${controller.historyListIdx.value}'),
                  constraints: BoxConstraints(maxHeight: 300, minHeight: 0),
                  child: Obx(
                    () => ListView.builder(
                      // shrink 控制 ListView 不会无脑填充外层的 box
                      shrinkWrap: true,
                      itemCount: controller.timeRecordList.length,
                      itemBuilder: (context, index) {
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
            ],
          ),
        ],
      );
    });
  }
}
