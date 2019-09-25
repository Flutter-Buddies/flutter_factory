import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_factory/ui/theme/game_theme.dart';

typedef ThemedWidgetBuilder = Widget Function(
  BuildContext context, GameTheme data);

typedef ThemeDataWithBrightnessBuilder = GameTheme Function(
  Brightness brightness);

class DynamicTheme extends StatefulWidget {
  const DynamicTheme(
    {Key key, this.data, this.themedWidgetBuilder, this.defaultBrightness})
    : super(key: key);

  final ThemedWidgetBuilder themedWidgetBuilder;
  final ThemeDataWithBrightnessBuilder data;
  final Brightness defaultBrightness;

  @override
  DynamicThemeState createState() => DynamicThemeState();

  static DynamicThemeState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<DynamicThemeState>());
  }
}

class DynamicThemeState extends State<DynamicTheme> {
  GameTheme _data;

  Brightness _brightness;

  GameTheme get data => _data;

  Brightness get brightness => _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = widget.defaultBrightness;
    _data = widget.data(_brightness);

    _brightness = Brightness.dark;
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

  Future<void> setBrightness(Brightness brightness) async {
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
