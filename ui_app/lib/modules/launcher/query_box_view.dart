import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:developer' as developer;

import 'package:extended_text_field/extended_text_field.dart';

class BjyQueryBoxView extends StatefulWidget {
  const BjyQueryBoxView({super.key});

  @override
  State<BjyQueryBoxView> createState() => _BjyQueryBoxViewState();
}

class _BjyQueryBoxViewState extends State<BjyQueryBoxView> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // 套路写法，每次点击按钮，触发 _incrementCounter，_counter 的值加 1
      _counter++;
    });
  }

  // final TextInputFocusNode _focusNode = TextInputFocusNode();

  KeyEventResult _handleKeyPress(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    // developer.log('onKeyEvent node', name: node.toStringDeep());
    debugPrint('key event: ${event.logicalKey}');
    _incrementCounter();
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          // 键盘事件会传到这里 除非 FocusNode.hasFocus == false
          child: Focus(
            onKeyEvent: _handleKeyPress,
            child: SizedBox(
              height: 55.0,
              child: Theme(
                data: ThemeData(textSelectionTheme: TextSelectionThemeData()),
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
                        // borderRadius: BorderRadius.circular(
                        //   WoxThemeUtil
                        //       .instance
                        //       .currentTheme
                        //       .value
                        //       .queryBoxBorderRadius
                        //       .toDouble(),
                        // ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      // fillColor: fromCssColor(
                      //   WoxThemeUtil
                      //       .instance
                      //       .currentTheme
                      //       .value
                      //       .queryBoxBackgroundColor,
                      // ),
                      hoverColor: Colors.transparent,
                    ),
                    // cursorColor: fromCssColor(
                    //   WoxThemeUtil
                    //       .instance
                    //       .currentTheme
                    //       .value
                    //       .queryBoxCursorColor,
                    // ),
                    focusNode: TextInputFocusNode(),
                    // controller: controller.queryBoxTextFieldController,
                    // scrollController: controller.queryBoxScrollController,
                    enableIMEPersonalizedLearning: true,
                    // inputFormatters: [
                    //   TextInputFormatter.withFunction((oldValue, newValue) {
                    //     var traceId = const UuidV4().generate();
                    //     Logger.instance.debug(
                    //       traceId,
                    //       "IME Formatter - old: ${oldValue.text}, new: ${newValue.text}, composing: ${newValue.composing}",
                    //     );

                    //     // Flutter's IME handling has inconsistencies across platforms, especially on Windows
                    //     // So we use input formatter to detect IME input completion instead of onChanged event
                    //     // Reference: https://github.com/flutter/flutter/issues/128565
                    //     //
                    //     // Issues:
                    //     // 1. isComposingRangeValid state is unstable on certain platforms
                    //     // 2. When IME input completes, the composing state changes occur in this order:
                    //     //    a. First, text content updates (e.g., from pinyin "wo'zhi'dao" to characters "我知道")
                    //     //    b. Then, the composing state is cleared (from valid to invalid)
                    //     //
                    //     // Solution:
                    //     // 1. Track composing range changes to more accurately detect when IME input completes
                    //     // 2. Use start and end positions to determine composing state instead of relying solely on isComposingRangeValid

                    //     // Check if both states are in IME editing mode
                    //     // composing.start >= 0 indicates an active IME composition region
                    //     bool wasComposing =
                    //         oldValue.composing.start >= 0 &&
                    //         oldValue.composing.end >= 0;
                    //     bool isComposing =
                    //         newValue.composing.start >= 0 &&
                    //         newValue.composing.end >= 0;

                    //     if (wasComposing && !isComposing) {
                    //       // Scenario 1: IME composition completed
                    //       // Transition from composing to non-composing state indicates user has finished word selection
                    //       // Example: The moment when "wo'zhi'dao" converts to "我知道"
                    //       Future.microtask(() {
                    //         Logger.instance.info(
                    //           traceId,
                    //           "IME: composition completed, start query: ${newValue.text}",
                    //         );
                    //         controller.onQueryBoxTextChanged(newValue.text);
                    //       });
                    //     } else if (!wasComposing &&
                    //         !isComposing &&
                    //         oldValue.text != newValue.text) {
                    //       // Scenario 2: Normal text input (non-IME)
                    //       // Text has changed but neither state is in IME composition
                    //       // Example: Direct input of English letters or numbers
                    //       Future.microtask(() {
                    //         Logger.instance.info(
                    //           traceId,
                    //           "IME: normal input, start query: ${newValue.text}",
                    //         );
                    //         controller.onQueryBoxTextChanged(newValue.text);
                    //       });
                    //     }

                    //     // Use Future.microtask to ensure query is triggered after text update is complete
                    //     // This prevents querying with incomplete state updates

                    //     return newValue;
                    //   }),
                    //   ],
                    // ),
                  ),
                ),
              ),
            ),
          ),
          // Positioned(
          // right: 10,
          // height: 55,
          //   child: WoxDragMoveArea(
          //     onDragEnd: () {
          //       controller.focusQueryBox();
          //     },
          //     child: Container(
          //       width: 55,
          //       height: 55,
          //       color: Colors.transparent,
          //       child: Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: MouseRegion(
          //           cursor: controller.queryIcon.value.action != null
          //               ? SystemMouseCursors.click
          //               : SystemMouseCursors.basic,
          //           child: GestureDetector(
          //             onTap: () {
          //               controller.queryIcon.value.action?.call();
          //               controller.focusQueryBox();
          //             },
          //             child: WoxImageView(
          //               woxImage: controller.queryIcon.value.icon,
          //               width: 24,
          //               height: 24,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ),
      ],
    );
  }
}
