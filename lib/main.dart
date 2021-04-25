import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_factory/game/money_manager/normal_manager.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/sandbox_bloc.dart';
import 'package:flutter_factory/ui/screens/challenges_page.dart';
import 'package:flutter_factory/ui/screens/main_page.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/game_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:flutter_factory/ui/theme/themes/dark_game_theme.dart';
import 'package:flutter_factory/ui/theme/themes/light_game_theme.dart';
import 'package:flutter_factory/ui/theme/themes/oled_dark_game_theme.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  TargetPlatform targetPlatform;
  if (kIsWeb) {
    targetPlatform = TargetPlatform.fuchsia;
  } else if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }

  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GameBloc _bloc;

  GameTheme _getTheme(ThemeType tt) {
    switch (tt) {
      case ThemeType.dark:
        return DarkGameTheme();
      case ThemeType.oledDark:
        return VeryDarkGameTheme();
      default:
        return LightGameTheme();
    }
  }

  @override
  void dispose() {
    _bloc.dispose();

    super.dispose();
  }

  void _goOnFloor() {
    _bloc.randomMainScreenFloor(0);
  }

  @override
  Widget build(BuildContext context) {
    _bloc ??= GameProvider.of(context) ?? GameBloc();
    _goOnFloor();

    /// b612MonoTextTheme, pressStart2p, firaCodeTextTheme, sulphurPointTextTheme
    return DynamicTheme(
      data: _getTheme,
      defaultThemeType: ThemeType.light,
      themedWidgetBuilder: (BuildContext context, GameTheme theme) {
        SystemChrome.setSystemUIOverlayStyle(
            theme.type == ThemeType.light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
        return AnimatedThemeProvider(
          duration: Duration(milliseconds: 450),
          data: theme,
          child: MaterialApp(
            theme: ThemeData.light().copyWith(textTheme: GoogleFonts.firaCodeTextTheme(ThemeData.light().textTheme)),
            darkTheme: ThemeData.dark().copyWith(textTheme: GoogleFonts.firaCodeTextTheme(ThemeData.dark().textTheme)),
            themeMode: theme.type == ThemeType.light ? ThemeMode.light : ThemeMode.dark,
            home: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: <Widget>[
                  GameProvider(
                    bloc: _bloc,
                    child: Stack(
                      children: <Widget>[
                        GameWidget(
                          isPreview: true,
                        ),
                      ],
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.2, sigmaY: 2.2),
                    child: Container(
                      color: DynamicTheme.of(context).data.voidColor.withOpacity(0.2),
                      child: HomeButtons(),
                    ),
                  )
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class HomeButtons extends StatelessWidget {
  HomeButtons({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('${Theme.of(context).textTheme.headline6.fontFamily}');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      margin: const EdgeInsets.only(bottom: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RaisedButton(
            child: Container(
              height: 80.0,
              margin: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Play',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: DynamicTheme.of(context).data.positiveActionIconColor),
                ),
              ),
            ),
            color: DynamicTheme.of(context).data.positiveActionButtonColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => Provider<GameBloc>(
                    create: (BuildContext context) => GameBloc(moneyManager: NormalMoneyManager()),
                    child: MainPage(),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.0),
          RaisedButton(
            child: Container(
                height: 20.0,
                margin: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Challenges',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: DynamicTheme.of(context).data.neutralActionIconColor),
                  ),
                )),
            color: DynamicTheme.of(context).data.neutralActionButtonColor,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) => ChallengesListPage()));
            },
          ),
          SizedBox(height: 24.0),
          RaisedButton(
            child: Container(
              height: 20.0,
              margin: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Sandbox',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: DynamicTheme.of(context).data.positiveActionIconColor),
                ),
              ),
            ),
            color: DynamicTheme.of(context).data.neutralActionButtonColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => Provider<GameBloc>(
                    create: (BuildContext context) => SandboxBloc(),
                    child: MainPage(),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
