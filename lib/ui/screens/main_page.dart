import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';
import 'package:flutter_factory/ui/widgets/slide_game_panel.dart';
import 'package:flutter_factory/util/utils.dart';
import 'package:provider/provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BackdropHolder();
  }
}

class BackdropHolder extends StatefulWidget {
  const BackdropHolder({Key key}) : super(key: key);

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

  Widget _showSettings() {
    final Color _textColor = DynamicTheme.of(context).data.textColor;

    return Container(
      padding: const EdgeInsets.all(12.0),
      width: MediaQuery.of(context).size.width * 0.8,
      color: ThemeProvider.of(context).menuColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const SizedBox(
            height: 40.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                backgroundColor: DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: _bloc.increaseGameSpeed,
                child: Icon(
                  Icons.chevron_left,
                  color: DynamicTheme.of(context).data.neutralActionIconColor,
                ),
              ),
              Text('Tick speed: ${_bloc.gameSpeed} ms',
                  style: Theme.of(context).textTheme.subtitle2.copyWith(color: _textColor)),
              FloatingActionButton(
                backgroundColor: DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: _bloc.decreaseGameSpeed,
                child: Icon(
                  Icons.chevron_right,
                  color: DynamicTheme.of(context).data.neutralActionIconColor,
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Show arrows',
              style: Theme.of(context).textTheme.subtitle2.copyWith(color: _textColor),
            ),
            subtitle: Text(
              'Visual representation on equipment',
              style: Theme.of(context).textTheme.caption.copyWith(color: _textColor),
            ),
            onChanged: (bool value) {
              setState(() {
                _bloc.showArrows = value;
              });
            },
            value: _bloc.showArrows,
          ),
          const SizedBox(
            height: 24.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Select type:',
                style: Theme.of(context).textTheme.button.copyWith(color: _textColor),
              ),
              Stack(
                children: <Widget>[
                  DropdownButton<SelectMode>(
                    onChanged: (SelectMode tt) {
                      _bloc.selectMode = tt;
                    },
                    style: Theme.of(context).textTheme.button.copyWith(color: _textColor),
                    value: _bloc.selectMode,
                    items: SelectMode.values.map((SelectMode tt) {
                      final TextStyle _style = Theme.of(context).textTheme.button;

                      return DropdownMenuItem<SelectMode>(
                        value: tt,
                        child: Text(
                          tt.toString(),
                          style: _style,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60.0,
                child: RaisedButton(
                  color: DynamicTheme.of(context).data.positiveActionButtonColor,
                  onPressed: () {
                    _bloc.equipment
                        .where((FactoryEquipmentModel fem) => fem is Dispenser)
                        .map<Dispenser>((FactoryEquipmentModel fem) => fem)
                        .forEach((Dispenser d) {
                      d.isWorking = true;
                    });
                  },
                  child: Text(
                    'Turn on all dispensers',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: DynamicTheme.of(context).data.positiveActionIconColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60.0,
                child: RaisedButton(
                  color: DynamicTheme.of(context).data.negativeActionButtonColor,
                  onPressed: () {
                    _bloc.equipment
                        .where((FactoryEquipmentModel fem) => fem is Dispenser)
                        .map<Dispenser>((FactoryEquipmentModel fem) => fem)
                        .forEach((Dispenser d) {
                      d.isWorking = false;
                    });
                  },
                  child: Text(
                    'Turn off all dispensers',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: DynamicTheme.of(context).data.negativeActionIconColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Theme:',
                    style: Theme.of(context).textTheme.button.copyWith(color: _textColor),
                  ),
                  Stack(
                    children: <Widget>[
                      DropdownButton<ThemeType>(
                        onChanged: (ThemeType tt) {
                          DynamicTheme.of(context).setThemeType(tt);
                        },
                        style: Theme.of(context).textTheme.button.copyWith(color: _textColor),
                        value: DynamicTheme.of(context).data.type,
                        items: ThemeType.values.map((ThemeType tt) {
                          final TextStyle _style = Theme.of(context).textTheme.button;

                          return DropdownMenuItem<ThemeType>(
                            value: tt,
                            child: Text(
                              getThemeName(tt),
                              style: _style,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text('Machines: ${_bloc.equipment.length}',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                Text('Materials: ${_bloc.material.length}',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                Text('Excess Materials: ${_bloc.getExcessMaterial.length}',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                Text('FPT: ${_bloc.frameRate}',
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            child: FlatButton(
              onPressed: () {
                void _clearMaterial(FactoryEquipmentModel fem) {
                  fem.objects.clear();
                }

                _bloc.equipment.forEach(_clearMaterial);
              },
              child: Text(
                'Vaporize all material on this floor',
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: DynamicTheme.of(context).data.negativeActionButtonColor, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          const SizedBox(height: 28.0),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            child: RaisedButton(
              color: DynamicTheme.of(context).data.negativeActionButtonColor,
              onPressed: () async {
                final bool _clear = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Clear?'),
                            content: const Text('Are you sure you want to clear this whole floor?'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(
                                  'CLEAR',
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      .copyWith(color: DynamicTheme.of(context).data.negativeActionButtonColor),
                                ),
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                              ),
                              const SizedBox(
                                width: 12.0,
                              ),
                              FlatButton(
                                child: const Text('CANCEL'),
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                              ),
                            ],
                          );
                        }) ??
                    false;

                if (_clear) {
                  _bloc.clearLine();
                }
              },
              child: Text(
                'CLEAR LINE',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: DynamicTheme.of(context).data.negativeActionIconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showFloors() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: DynamicTheme.of(context).data.menuColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const SizedBox.shrink(),
          Container(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Icon(
                    Icons.chevron_left,
                    color: ThemeProvider.of(context).textColor,
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Current floor:',
                      style: Theme.of(context).textTheme.button,
                    ),
                    Text(
                      '${_bloc.floor}',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 60.0,
              ),
              const Divider(),
              Column(
                children: List<Widget>.generate(4, (int index) {
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _bloc.changeFloor(index);
                      },
                      child: Container(height: 80.0, child: Center(child: Text(_bloc.getFloorName(floor: index)))),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox.shrink()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _bloc = Provider.of<GameBloc>(context);

    return StreamBuilder<GameUpdate>(
        stream: _bloc.gameUpdate,
        builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot) {
          return Scaffold(
            key: _key,
            drawer: _showFloors(),
            endDrawer: _showSettings(),
            body: GameProvider(
              bloc: _bloc,
              child: Stack(
                children: <Widget>[
                  const GameWidget(),
                  const SlideGamePanel(),
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
                            .headline5
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
                                            .subtitle2
                                            .copyWith(color: DynamicTheme.of(context).data.textColor),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            createDisplay(_bloc.moneyManager.currentCredit),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                .copyWith(color: DynamicTheme.of(context).data.textColor),
                                          ),
                                          const SizedBox(
                                            width: 24.0,
                                          ),
                                          Icon(
                                            Icons.show_chart,
                                            size: 20.0,
                                            color: _bloc.lastTickEarnings.isNegative
                                                ? DynamicTheme.of(context).data.negativeActionButtonColor
                                                : DynamicTheme.of(context).data.positiveActionButtonColor,
                                          ),
                                          const SizedBox(
                                            width: 4.0,
                                          ),
                                          Text(
                                            createDisplay(_bloc.lastTickEarnings),
                                            style: Theme.of(context).textTheme.headline6.copyWith(
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
                            const SizedBox(
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
