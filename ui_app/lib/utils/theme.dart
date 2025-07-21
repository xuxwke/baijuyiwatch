import 'package:flutter/material.dart';

String formatDuration(int seconds) {
  if (seconds < 60) {
    return '${seconds.toString().padLeft(2, ' ')} 秒';
  } else if (seconds < 3600) {
    int min = seconds ~/ 60;
    return '${min.toString().padLeft(2, ' ')} 分';
  } else {
    int hour = seconds ~/ 3600;
    return '${hour.toString().padLeft(2, ' ')} 时';
  }
}

class BjyTheme {
  final Color inputBoxBgColor;
  final Color inputBoxTextColor;
  final Color inputBoxButtonTextColor;
  final Color historyItemBgColorActive;

  final Color historyItemBgColor;
  final Color historyItemTextColor;

  BjyTheme({
    required this.inputBoxBgColor,
    required this.inputBoxTextColor,
    required this.inputBoxButtonTextColor,
    required this.historyItemBgColor,
    required this.historyItemBgColorActive,
    required this.historyItemTextColor,
  });

  static Color hexToColor(String hex) {
    String formatted = hex.replaceAll('#', '');
    if (formatted.length == 6) {
      formatted = 'FF$formatted'; // 默认不透明
    }
    return Color(int.parse(formatted, radix: 16));
  }

  factory BjyTheme.empty() {
    return BjyTheme(
      inputBoxBgColor: hexToColor('C9E9D2'),
      inputBoxTextColor: hexToColor('789DBC'),
      inputBoxButtonTextColor: hexToColor('789DBC'),
      historyItemBgColor: hexToColor('FEF9F2'),
      historyItemBgColorActive: hexToColor('E9F9E2'),
      historyItemTextColor: hexToColor('789DBC'),
    );

    return BjyTheme(
      inputBoxBgColor: hexToColor('E7CCCC'),
      inputBoxTextColor: hexToColor('A5B68D'),
      inputBoxButtonTextColor: hexToColor('89A8B2'),
      historyItemBgColor: hexToColor('EDE8DC'),
      historyItemBgColorActive: hexToColor('E7DCCC'),
      historyItemTextColor: hexToColor('A5B68D'),
    );
  }
}

var defaultTheme = BjyTheme.empty();
