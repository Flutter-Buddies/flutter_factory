import 'dart:ui';

import 'package:flutter/material.dart';

import 'game_theme.dart';

class DarkGameTheme implements GameTheme{
  const DarkGameTheme();

  @override Color get floorColor => Colors.black;
  @override Color get voidColor => Colors.grey.shade900;
  @override Color get textColor => Colors.white60;
  @override Color get separatorsColor => Colors.grey.shade800;

  @override Color get machineAccentDarkColor => Colors.blueGrey.shade900;
  @override Color get machineAccentColor => Colors.blueGrey.shade800;
  @override Color get machineAccentLightColor => Colors.blueGrey.shade700;

  @override Color get machinePrimaryDarkColor => Colors.grey.shade800;
  @override Color get machinePrimaryColor => Colors.grey.shade600;
  @override Color get machinePrimaryLightColor => Colors.grey.shade500;

  @override Color get machineActiveColor => Colors.green.shade800;
  @override Color get machineInActiveColor => Colors.orange;

  @override Color get melterActiveColor => Colors.red;

  @override Color get machineWarningColor => Colors.deepOrange.shade400;

  @override Color get rollerDividersColor => Colors.grey.shade700;
  @override Color get rollersColor => Colors.grey.shade900;

  @override Color get selectedTileColor => Colors.green.shade800;
}