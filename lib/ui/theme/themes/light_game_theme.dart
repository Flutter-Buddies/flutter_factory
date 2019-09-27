import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';

import '../game_theme.dart';

class LightGameTheme implements GameTheme{
  const LightGameTheme();

  @override Color get floorColor => Colors.grey;
  @override Color get textColor => Colors.black87;
  @override Color get voidColor => Colors.white;
  @override Color get separatorsColor => Colors.grey.shade400;

  @override Color get machineAccentDarkColor => Colors.grey.shade400;
  @override Color get machineAccentColor => Colors.grey.shade200;
  @override Color get machineAccentLightColor => Colors.white;

  @override Color get machinePrimaryDarkColor => Colors.grey.shade900;
  @override Color get machinePrimaryColor => Colors.grey.shade700;
  @override Color get machinePrimaryLightColor => Colors.grey.shade600;

  @override Color get machineActiveColor => Colors.green;
  @override Color get machineInActiveColor => Colors.red;
  @override Color get melterActiveColor => Colors.red;

  @override Color get machineWarningColor => Colors.yellow;

  @override Color get rollerDividersColor => Colors.grey;
  @override Color get rollersColor => Colors.grey.shade800;

  @override Color get selectedTileColor => Colors.orange;

  @override ThemeType get type => ThemeType.light;

  @override Color get negativeActionButtonColor => Colors.red;
  @override Color get negativeActionIconColor => Colors.white;
  @override Color get neutralActionButtonColor => Colors.blue;
  @override Color get neutralActionIconColor => Colors.white;
  @override Color get positiveActionButtonColor => Colors.green;
  @override Color get positiveActionIconColor => Colors.white;
  @override Color get modifyActionButtonColor => Colors.yellow.shade600;
  @override Color get modifyActionIconColor => Colors.white;
}