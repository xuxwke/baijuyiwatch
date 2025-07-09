import 'package:flutter/material.dart';
import 'package:bjy/components/bjy_border_drag_move_view.dart';
import 'package:bjy/modules/launcher/query_box_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // 套路写法，每次点击按钮，触发 _incrementCounter，_counter 的值加 1
      _counter++;
    });
  }

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


// stack, column, expanded, padding, column, BjyQueryBoxView
// BjyQueryBoxView: Stack, Positioned, Focus, SizedBox, ExtendedTextField