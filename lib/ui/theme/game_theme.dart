import 'package:flutter/material.dart';
import 'package:flutter_factory/ui/theme/light_game_theme.dart';

import 'dynamic_theme.dart';

abstract class GameTheme{
  GameTheme({
    this.type,
    this.floorColor,
    this.voidColor,
    this.selectedTileColor,
    this.separatorsColor,
    this.textColor,
    this.machinePrimaryColor,
    this.machinePrimaryLightColor,
    this.machinePrimaryDarkColor,
    this.machineAccentColor,
    this.machineAccentLightColor,
    this.machineAccentDarkColor,
    this.machineActiveColor,
    this.machineInActiveColor,
    this.machineWarningColor,
    this.rollerDividersColor,
    this.rollersColor,
    this.melterActiveColor
  });

  final ThemeType type;

  final Color selectedTileColor;

  final Color floorColor;
  final Color textColor;
  final Color voidColor;
  final Color separatorsColor;

  final Color machinePrimaryDarkColor;
  final Color machinePrimaryColor;
  final Color machinePrimaryLightColor;
  final Color machineAccentDarkColor;
  final Color machineAccentColor;
  final Color machineAccentLightColor;

  final Color machineWarningColor;
  final Color melterActiveColor;

  final Color machineActiveColor;
  final Color machineInActiveColor;

  final Color rollersColor;
  final Color rollerDividersColor;

  static GameTheme lerp(GameTheme begin, GameTheme end, double t){
    return _GameTheme(
      floorColor: Color.lerp(begin.floorColor, end.floorColor, t),
      voidColor: Color.lerp(begin.voidColor, end.voidColor, t),
      selectedTileColor: Color.lerp(begin.selectedTileColor, end.selectedTileColor, t),
      separatorsColor: Color.lerp(begin.separatorsColor, end.separatorsColor, t),
      machinePrimaryColor: Color.lerp(begin.machinePrimaryColor, end.machinePrimaryColor, t),
      machinePrimaryLightColor: Color.lerp(begin.machinePrimaryLightColor, end.machinePrimaryLightColor, t),
      machinePrimaryDarkColor: Color.lerp(begin.machinePrimaryDarkColor, end.machinePrimaryDarkColor, t),
      machineAccentColor: Color.lerp(begin.machineAccentColor, end.machineAccentColor, t),
      machineAccentLightColor: Color.lerp(begin.machineAccentLightColor, end.machineAccentLightColor, t),
      machineAccentDarkColor: Color.lerp(begin.machineAccentDarkColor, end.machineAccentDarkColor, t),
      melterActiveColor: Color.lerp(begin.melterActiveColor, end.melterActiveColor, t),
      machineActiveColor: Color.lerp(begin.machineActiveColor, end.machineActiveColor, t),
      machineInActiveColor: Color.lerp(begin.machineInActiveColor, end.machineInActiveColor, t),
      rollerDividersColor: Color.lerp(begin.rollerDividersColor, end.rollerDividersColor, t),
      rollersColor: Color.lerp(begin.rollersColor, end.rollersColor, t),
      textColor: Color.lerp(begin.textColor, end.textColor, t),
      machineWarningColor: Color.lerp(begin.machineWarningColor, end.machineWarningColor, t),
    );
  }
}

class _GameTheme implements GameTheme{
  _GameTheme({
    @required this.type,
    @required this.floorColor,
    @required this.voidColor,
    @required this.textColor,
    @required this.selectedTileColor,
    @required this.separatorsColor,
    @required this.machinePrimaryColor,
    @required this.machinePrimaryLightColor,
    @required this.machinePrimaryDarkColor,
    @required this.machineAccentColor,
    @required this.machineAccentLightColor,
    @required this.machineAccentDarkColor,
    @required this.machineActiveColor,
    @required this.machineInActiveColor,
    @required this.machineWarningColor,
    @required this.rollerDividersColor,
    @required this.rollersColor,
    @required this.melterActiveColor,
  });

  @override final ThemeType type;
  @override final Color floorColor;
  @override final Color textColor;
  @override final Color machineAccentColor;
  @override final Color machineAccentDarkColor;
  @override final Color machineAccentLightColor;
  @override final Color machineActiveColor;
  @override final Color machineInActiveColor;
  @override final Color machinePrimaryColor;
  @override final Color machinePrimaryDarkColor;
  @override final Color machinePrimaryLightColor;
  @override final Color machineWarningColor;
  @override final Color melterActiveColor;
  @override final Color rollerDividersColor;
  @override final Color rollersColor;
  @override final Color selectedTileColor;
  @override final Color separatorsColor;
  @override final Color voidColor;
}