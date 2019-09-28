import 'dart:ui';

import 'package:flutter/material.dart';

import '../dynamic_theme.dart';
import '../game_theme.dart';

class DarkGameTheme implements GameTheme{
  const DarkGameTheme();

  @override Color get floorColor => Colors.grey.shade700;
  @override Color get voidColor => Colors.black;
  @override Color get textColor => Colors.white60;
  @override Color get separatorsColor => Colors.grey.shade800;

  @override Color get machineAccentDarkColor => Colors.grey.shade200;
  @override Color get machineAccentColor => Colors.grey.shade400;
  @override Color get machineAccentLightColor => Colors.grey.shade500;

  @override Color get machinePrimaryDarkColor => Colors.blueGrey.shade900;
  @override Color get machinePrimaryColor => Colors.blueGrey.shade800;
  @override Color get machinePrimaryLightColor => Colors.blueGrey.shade700;

  @override Color get machineActiveColor => Colors.green.shade800;
  @override Color get machineInActiveColor => Colors.red.shade800;

  @override Color get melterActiveColor => Colors.red;

  @override Color get machineWarningColor => Colors.deepOrange.shade400;

  @override Color get rollerDividersColor => Colors.grey.shade700;
  @override Color get rollersColor => Colors.grey.shade900;

  @override Color get selectedTileColor => Colors.green.shade800.withOpacity(0.6);

  @override ThemeType get type => ThemeType.dark;

  @override Color get negativeActionButtonColor => Colors.red.shade900;
  @override Color get negativeActionIconColor => Colors.white;
  @override Color get neutralActionButtonColor => Colors.grey.shade600;
  @override Color get neutralActionIconColor => Colors.white;
  @override Color get positiveActionButtonColor => Colors.green.shade600;
  @override Color get positiveActionIconColor => Colors.white;
  @override Color get modifyActionButtonColor => Colors.orange.shade600;
  @override Color get modifyActionIconColor => Colors.white;
}