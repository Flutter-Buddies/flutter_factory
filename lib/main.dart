import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_factory/game/model/unlockables_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/screens/challenges_page.dart';
import 'package:flutter_factory/ui/screens/main_page.dart';
import 'package:flutter_factory/ui/theme/themes/dark_game_theme.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/game_theme.dart';
import 'package:flutter_factory/ui/theme/themes/light_game_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:flutter_factory/ui/theme/themes/oled_dark_game_theme.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';
import 'package:url_launcher/url_launcher.dart';

void main(){
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
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
  GameItems _items;

  GameTheme _getTheme(ThemeType tt){
    switch(tt){
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

  void _goOnFloor(){
    _bloc.randomMainScreenFloor(Random().nextInt(4));
  }

  @override
  Widget build(BuildContext context) {
    _bloc ??= GameProvider.of(context) ?? GameBloc();

    _bloc.gameCameraPosition.scale = 1.0 + Random().nextDouble() * 0.5;
    _bloc.gameCameraPosition.position = Offset(Random().nextDouble() * -200.0 * _bloc.gameCameraPosition.scale, Random().nextDouble() * -200.0 * _bloc.gameCameraPosition.scale);
    _goOnFloor();

    return DynamicTheme(
      data: _getTheme,
      defaultThemeType: ThemeType.light,
      themedWidgetBuilder: (BuildContext context, GameTheme theme){
        SystemChrome.setSystemUIOverlayStyle(theme.type == ThemeType.light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
        return AnimatedThemeProvider(
          duration: Duration(milliseconds: 450),
          data: theme,
          child: MaterialApp(
            theme: theme.type == ThemeType.light ? ThemeData.light() : ThemeData.dark(),
            home: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Stack(
                  children: <Widget>[
                    GameProvider(
                      bloc: _bloc,
                      child: Stack(
                        children: <Widget>[
                          GameWidget(),
                        ],
                      ),
                    ),

                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.2, sigmaY: 3.2),
                      child: Container(
                        color: DynamicTheme.of(context).data.voidColor.withOpacity(0.2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 36.0),
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    RaisedButton(
                                      child: Container(
                                        height: 60.0,
                                        margin: const EdgeInsets.all(24.0),
                                        child: Center(
                                          child: Text('Play',
                                            style: Theme.of(context).textTheme.title.copyWith(color: DynamicTheme.of(context).data.positiveActionIconColor),
                                          ),
                                        ),
                                      ),
                                      color: DynamicTheme.of(context).data.positiveActionButtonColor,
                                      onPressed: (){
                                        Navigator.push(context, MaterialPageRoute<void>(
                                          builder: (BuildContext context) => MainPage()
                                        ));
                                      },
                                    ),
                                    SizedBox(height: 24.0),
                                    RaisedButton(
                                      child: Container(
                                        height: 40.0,
                                        margin: const EdgeInsets.all(24.0),
                                        child: Center(
                                          child: Text('Challenges',
                                            style: Theme.of(context).textTheme.title.copyWith(fontSize: 14.0, color: DynamicTheme.of(context).data.neutralActionIconColor),
                                          ),
                                        )
                                      ),
                                      color: DynamicTheme.of(context).data.neutralActionButtonColor,
                                      onPressed: (){
                                        Navigator.push(context, MaterialPageRoute<void>(
                                          builder: (BuildContext context) => ChallengesListPage()
                                        ));
                                      },
                                    )
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
                                child: RaisedButton(
                                  color: Colors.deepPurple,
                                  child: Container(
                                    margin: const EdgeInsets.all(24.0),
                                    child: Text('Discord',
                                      style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
                                    )
                                  ),
                                  onPressed: _launchURL,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }
            ),
          ),
        );
      },
    );
  }

  void _launchURL() async {
    const url = 'https://discordapp.com/invite/hBNwHvb';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
