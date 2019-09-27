import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/screens/challenges_page.dart';
import 'package:flutter_factory/ui/screens/main_page.dart';
import 'package:flutter_factory/ui/theme/dark_game_theme.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/game_theme.dart';
import 'package:flutter_factory/ui/theme/light_game_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      data: (ThemeType b) => b == ThemeType.dark ? DarkGameTheme() : LightGameTheme(),
      themedWidgetBuilder: (BuildContext context, GameTheme theme){
        return AnimatedThemeProvider(
          duration: Duration(milliseconds: 450),
          data: theme,
          child: MaterialApp(
            home: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Stack(
                  children: <Widget>[
                    GameProvider(
                      bloc: GameProvider.of(context) ?? GameBloc(),
                      child: Stack(
                        children: <Widget>[
                          GameWidget(),
                        ],
                      ),
                    ),


                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                      child: Container(
                        color: Colors.white24,
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
                                        margin: const EdgeInsets.all(24.0),
                                        child: Text('Play',
                                          style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
                                        ),
                                      ),
                                      color: Colors.blue,
                                      onPressed: (){
                                        Navigator.push(context, MaterialPageRoute<void>(
                                          builder: (BuildContext context) => MainPage()
                                        ));
                                      },
                                    ),
                                    SizedBox(height: 24.0),
                                    RaisedButton(
                                      child: Container(
                                        margin: const EdgeInsets.all(24.0),
                                        child: Text('Challenges')
                                      ),
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
