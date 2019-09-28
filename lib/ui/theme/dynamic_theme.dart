import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_factory/ui/theme/game_theme.dart';

enum ThemeType{
  light,
  dark,
  oledDark
}

String getThemeName(ThemeType type){
  switch(type){
    case ThemeType.light: return 'Light';
    case ThemeType.dark: return 'Dark';
    case ThemeType.oledDark: return 'OLED Dark';
  }
}

typedef ThemedWidgetBuilder = Widget Function(
  BuildContext context, GameTheme data);

typedef ThemeDataWithThemeTypeBuilder = GameTheme Function(
  ThemeType brightness);

class DynamicTheme extends StatefulWidget {
  const DynamicTheme(
    {Key key, this.data, this.themedWidgetBuilder, this.defaultThemeType})
    : super(key: key);

  final ThemedWidgetBuilder themedWidgetBuilder;
  final ThemeDataWithThemeTypeBuilder data;
  final ThemeType defaultThemeType;

  @override
  DynamicThemeState createState() => DynamicThemeState();

  static DynamicThemeState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<DynamicThemeState>());
  }
}

class DynamicThemeState extends State<DynamicTheme> {
  GameTheme _data;

  ThemeType _brightness;

  GameTheme get data => _data;

  ThemeType get brightness => _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = widget.defaultThemeType;
    _data = widget.data(_brightness);

    _brightness = ThemeType.light;
    _data = widget.data(_brightness);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = widget.data(_brightness);
  }

  @override
  void didUpdateWidget(DynamicTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    _data = widget.data(_brightness);
  }

  Future<void> setThemeType(ThemeType brightness) async {
    setState(() {
      _data = widget.data(brightness);
      _brightness = brightness;
    });
  }

  void setThemeData(GameTheme data) {
    setState(() {
      _data = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return widget.themedWidgetBuilder(context, _data);
  }
}
