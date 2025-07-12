import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:bjy/controllers/query_box_controller.dart';
import 'package:bjy/components/bjy_border_drag_move_view.dart';
import 'package:bjy/modules/launcher/query_box_view.dart';

void main() async {
  // 套路: GetView Obx 中使用 controller 需要先注册
  Get.put(QueryBoxController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // build 方法是响应式的, 内容变了会自动重新画
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        // textTheme: SystemChineseFont.textTheme(Brightness.light),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  // 规定: StatefulWidget 子类里面的字段只能是 final 类型, 只能被赋值一次
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return WoxBorderDragMoveArea(
      borderWidth: 10.0,
      onDragEnd: () {
        // if (launcherController.isInSettingView.value) {
        //   return;
        // }

        // launcherController.focusQueryBox();
      },
      child: const Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(),
              child: Column(
                children: [
                  BjyQueryBoxView(),
                  // Expanded(child: WoxQueryResultView()),
                ],
              ),
            ),
          ),
        ],
      ),
      //     ? const WoxSettingView()
      //     : const WoxLauncherView(),
    );
  }
}
