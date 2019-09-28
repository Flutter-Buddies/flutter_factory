import 'dart:ui';

import 'package:flutter/material.dart';

import '../dynamic_theme.dart';
import '../game_theme.dart';

class VeryDarkGameTheme implements GameTheme{
  const VeryDarkGameTheme();

  @override Color get floorColor => Colors.black;
  @override Color get voidColor => Colors.grey.shade900;
  @override Color get textColor => Colors.white60;
  @override Color get separatorsColor => Colors.grey.shade800;

  @override Color get machineAccentDarkColor => Colors.grey.shade900;
  @override Color get machineAccentColor => Colors.grey.shade800;
  @override Color get machineAccentLightColor => Colors.grey.shade700;

  @override Color get machinePrimaryDarkColor => Color(0xFF001F42);
  @override Color get machinePrimaryColor => Color(0xFF003C80);
  @override Color get machinePrimaryLightColor => Color(0xFF005BC2);

  @override Color get machineActiveColor => Colors.lightBlue;
  @override Color get machineInActiveColor => Colors.orange;

  @override Color get melterActiveColor => Colors.orangeAccent;

  @override Color get machineWarningColor => Colors.deepOrange.shade400;

  @override Color get rollerDividersColor => Colors.grey.shade700;
  @override Color get rollersColor => Colors.grey.shade900;

  @override Color get selectedTileColor => Colors.blue.shade800.withOpacity(0.6);

  @override ThemeType get type => ThemeType.oledDark;

  @override Color get negativeActionButtonColor => Colors.red.shade900;
  @override Color get negativeActionIconColor => Colors.white;
  @override Color get neutralActionButtonColor => Colors.blueGrey.shade800;
  @override Color get neutralActionIconColor => Colors.white;
  @override Color get positiveActionButtonColor => Colors.green.shade800;
  @override Color get positiveActionIconColor => Colors.white;
  @override Color get modifyActionButtonColor => Colors.orange.shade600;
  @override Color get modifyActionIconColor => Colors.white;
}