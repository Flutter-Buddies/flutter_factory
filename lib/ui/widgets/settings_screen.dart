import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _textColor = DynamicTheme.of(context).data.textColor;
    GameBloc _bloc = Provider.of<GameBloc>(context);

    return Container(
      padding: const EdgeInsets.all(12.0),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height,
      color: ThemeProvider.of(context).menuColor,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
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
                    style: Theme.of(context).textTheme.subtitle.copyWith(color: _textColor)),
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
                style: Theme.of(context).textTheme.subtitle.copyWith(color: _textColor),
              ),
              subtitle: Text(
                'Visual representation on equipment',
                style: Theme.of(context).textTheme.caption.copyWith(color: _textColor),
              ),
              onChanged: (bool value) {
                _bloc.showArrows = value;
              },
              value: _bloc.showArrows,
            ),
            SizedBox(
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
                        TextStyle _style = Theme.of(context).textTheme.button;

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
                          .subhead
                          .copyWith(color: DynamicTheme.of(context).data.positiveActionIconColor),
                    ),
                  ),
                ),
                SizedBox(
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
                          .subhead
                          .copyWith(color: DynamicTheme.of(context).data.negativeActionIconColor),
                    ),
                  ),
                ),
                SizedBox(
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
                            TextStyle _style = Theme.of(context).textTheme.button;

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
                  _bloc.equipment.forEach((FactoryEquipmentModel fem) {
                    fem.objects.clear();
                  });
                },
                child: Text(
                  'Vaporize all material on this floor',
                  style: Theme.of(context).textTheme.subhead.copyWith(
                      color: DynamicTheme.of(context).data.negativeActionButtonColor, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            SizedBox(height: 28.0),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 80.0,
              child: RaisedButton(
                color: DynamicTheme.of(context).data.negativeActionButtonColor,
                onPressed: () async {
                  bool _clear = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Clear?'),
                              content: Text('Are you sure you want to clear this whole floor?'),
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
                                SizedBox(
                                  width: 12.0,
                                ),
                                FlatButton(
                                  child: Text('CANCEL'),
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
                      .subhead
                      .copyWith(color: DynamicTheme.of(context).data.negativeActionIconColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
