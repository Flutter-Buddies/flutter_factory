import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/widgets/floors_screen.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';
import 'package:flutter_factory/ui/widgets/settings_screen.dart';
import 'package:flutter_factory/ui/widgets/slide_game_panel.dart';
import 'package:flutter_factory/util/utils.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  MainPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropHolder();
  }
}

class BackdropHolder extends StatefulWidget {
  BackdropHolder({Key key}) : super(key: key);

  @override
  _BackdropHolderState createState() => new _BackdropHolderState();
}

class _BackdropHolderState extends State<BackdropHolder> with SingleTickerProviderStateMixin {
  GameBloc _bloc;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = Provider.of<GameBloc>(context);

    return StreamBuilder<GameUpdate>(
        stream: _bloc.gameUpdate,
        builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot) {
          /// TODO: Add bottom navigation bar (game/upgrades/receipts/floors)
          return Scaffold(
            key: _key,
            drawer: FloorsScreen(),
            endDrawer: SettingsScreen(),
            body: GameProvider(
              bloc: _bloc,
              child: Stack(
                children: <Widget>[
                  GameWidget(),
                  SlideGamePanel(),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: DynamicTheme.of(context).data.voidColor.withOpacity(0.2),
                      child: Text(
                        '${_bloc.frameRate}',
                        style: Theme.of(context)
                            .textTheme
                            .headline
                            .copyWith(color: DynamicTheme.of(context).data.textColor, fontWeight: FontWeight.w200),
                      ),
                    ),
                  ),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                      child: Container(
                        height: 110.0,
                        color: DynamicTheme.of(context).data.voidColor.withOpacity(0.2),
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      _key.currentState.openDrawer();
                                    },
                                    child: Icon(
                                      Icons.menu,
                                      color: DynamicTheme.of(context).data.textColor,
                                    ),
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        _bloc.floor,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle
                                            .copyWith(color: DynamicTheme.of(context).data.textColor),
                                      ),
                                      SizedBox(height: 4.0),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            createDisplay(_bloc.moneyManager.currentCredit),
                                            style: Theme.of(context)
                                                .textTheme
                                                .title
                                                .copyWith(color: DynamicTheme.of(context).data.textColor),
                                          ),
                                          SizedBox(
                                            width: 24.0,
                                          ),
                                          Icon(
                                            Icons.show_chart,
                                            size: 20.0,
                                            color: _bloc.lastTickEarnings.isNegative
                                                ? DynamicTheme.of(context).data.negativeActionButtonColor
                                                : DynamicTheme.of(context).data.positiveActionButtonColor,
                                          ),
                                          SizedBox(
                                            width: 4.0,
                                          ),
                                          Text(
                                            createDisplay(_bloc.lastTickEarnings),
                                            style: Theme.of(context).textTheme.title.copyWith(
                                                color: _bloc.lastTickEarnings.isNegative
                                                    ? DynamicTheme.of(context).data.negativeActionButtonColor
                                                    : DynamicTheme.of(context).data.positiveActionButtonColor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _key.currentState.openEndDrawer();
                                    },
                                    child: Icon(
                                      Icons.settings,
                                      color: DynamicTheme.of(context).data.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: MediaQuery.of(context).size.width * _bloc.progress,
                                height: 4.0,
                                color: DynamicTheme.of(context).data.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
