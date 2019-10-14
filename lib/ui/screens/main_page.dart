import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/themes/dark_game_theme.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/themes/light_game_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_ticker.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/build_equipment_widget.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/crafter_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/dispenser_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/free_roller_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/portal_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/selected_object_footer.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/selected_object_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/seller_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/sorter_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/splitter_options.dart';
import 'package:flutter_factory/ui/widgets/slide_game_panel.dart';

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

class _BackdropHolderState extends State<BackdropHolder> with SingleTickerProviderStateMixin{
  GameBloc _bloc;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  void dispose(){
    _bloc.dispose();
    super.dispose();
  }

  Widget _showSettings(){
    Color _textColor = DynamicTheme.of(context).data.textColor;

    return Container(
      padding: const EdgeInsets.all(12.0),
      width: MediaQuery.of(context).size.width * 0.8,
      color: ThemeProvider.of(context).menuColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(height: 40.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                backgroundColor:  DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: _bloc.increaseGameSpeed,
                child: Icon(Icons.chevron_left, color:  DynamicTheme.of(context).data.neutralActionIconColor,),
              ),
              Text('Tick speed: ${_bloc.gameSpeed} ms', style: Theme.of(context).textTheme.subtitle.copyWith(color: _textColor)),
              FloatingActionButton(
                backgroundColor:  DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: _bloc.decreaseGameSpeed,
                child: Icon(Icons.chevron_right, color:  DynamicTheme.of(context).data.neutralActionIconColor,),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Show arrows', style: Theme.of(context).textTheme.subtitle.copyWith(color: _textColor),),
            subtitle: Text('Visual representation on equipment', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor),),
            onChanged: (bool value){
              setState(() {
                _bloc.showArrows = value;
              });
            },
            value: _bloc.showArrows,
          ),

          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60.0,
                child: RaisedButton(
                  color:  DynamicTheme.of(context).data.positiveActionButtonColor,
                  onPressed: (){
                    _bloc.equipment.where((FactoryEquipmentModel fem) => fem is Dispenser).map<Dispenser>((FactoryEquipmentModel fem) => fem).forEach((Dispenser d){
                      d.isWorking = true;
                    });
                  },
                  child: Text('Turn on all dispensers', style: Theme.of(context).textTheme.subhead.copyWith(color:  DynamicTheme.of(context).data.positiveActionIconColor),),
                ),
              ),
              SizedBox(height: 8.0,),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60.0,
                child: RaisedButton(
                  color:  DynamicTheme.of(context).data.negativeActionButtonColor,
                  onPressed: (){
                    _bloc.equipment.where((FactoryEquipmentModel fem) => fem is Dispenser).map<Dispenser>((FactoryEquipmentModel fem) => fem).forEach((Dispenser d){
                      d.isWorking = false;
                    });
                  },
                  child: Text('Turn off all dispensers', style: Theme.of(context).textTheme.subhead.copyWith(color:  DynamicTheme.of(context).data.negativeActionIconColor),),
                ),
              ),

              SizedBox(height: 24.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Theme:', style: Theme.of(context).textTheme.button.copyWith(color: _textColor),),
                  Stack(
                    children: <Widget>[
                      DropdownButton<ThemeType>(
                        onChanged: (ThemeType tt){
                          DynamicTheme.of(context).setThemeType(tt);
                        },
                        style: Theme.of(context).textTheme.button.copyWith(color: _textColor),
                        value: DynamicTheme.of(context).data.type,
                        items: ThemeType.values.map((ThemeType tt){
                          TextStyle _style = Theme.of(context).textTheme.button;

                          return DropdownMenuItem<ThemeType>(
                            value: tt,
                            child: Text(getThemeName(tt),
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
                Text('Machines: ${_bloc.equipment.length}', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                Text('Materials: ${_bloc.material.length}', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                Text('Excess Materials: ${_bloc.getExcessMaterial.length}', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                Text('FPT: ${_bloc.frameRate}', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            child: FlatButton(
              onPressed: (){
                _bloc.equipment.forEach((FactoryEquipmentModel fem){
                  fem.objects.clear();
                });
              },
              child: Text('Vaporize all material on this floor', style: Theme.of(context).textTheme.subhead.copyWith(color:  DynamicTheme.of(context).data.negativeActionButtonColor, fontWeight: FontWeight.w400),),
            ),
          ),
          SizedBox(height: 28.0),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            child: RaisedButton(
              color:  DynamicTheme.of(context).data.negativeActionButtonColor,
              onPressed: () async {
                bool _clear = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text('Clear?'),
                      content: Text('Are you sure you want to clear this whole floor?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('CLEAR', style: Theme.of(context).textTheme.button.copyWith(color: DynamicTheme.of(context).data.negativeActionButtonColor),),
                          onPressed: (){
                            Navigator.pop(context, true);
                          },
                        ),

                        SizedBox(width: 12.0,),

                        FlatButton(
                          child: Text('CANCEL'),
                          onPressed: (){
                            Navigator.pop(context, false);
                          },
                        ),
                      ],
                    );
                  }
                ) ?? false;

                if(_clear){
                  _bloc.clearLine();
                }
              },
              child: Text('CLEAR LINE', style: Theme.of(context).textTheme.subhead.copyWith(color:  DynamicTheme.of(context).data.negativeActionIconColor),),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showFloors(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: DynamicTheme.of(context).data.menuColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Current floor:',
                  style: Theme.of(context).textTheme.button,
                ),
                Text('${_bloc.floor}',
                  style: Theme.of(context).textTheme.button,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60.0,
          ),
          Divider(),
          Material(
            type: MaterialType.transparency,
              child: InkWell(
              onTap: (){
                Navigator.pop(context);
                _bloc.changeFloor(0);
              },
              child: Container(
                height: 80.0,
                child: Center(child: Text('Ground floor'))
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
                  child: InkWell(
              onTap: (){
                Navigator.pop(context);
                _bloc.changeFloor(1);
              },
              child: Container(
                height: 80.0,
                child: Center(child: Text('First floor'))
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
                _bloc.changeFloor(2);
              },
              child: Container(
                height: 80.0,
                child: Center(child: Text('Second floor'))
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
                _bloc.changeFloor(3);
              },
              child: Container(
                height: 80.0,
                child: Center(child: Text('Secret floor'))
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showFab(){
    if(_bloc.selectedTiles.isEmpty){
      return null;
    }

    final List<FactoryEquipmentModel> _selectedEquipment = _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList();
    final bool _isSameEquipment = _selectedEquipment.every((FactoryEquipmentModel fe) => fe.type == _selectedEquipment.first.type) && _selectedEquipment.length == _bloc.selectedTiles.length;

    if(_bloc.selectedTiles.length > 1 && _selectedEquipment.isNotEmpty && !_isSameEquipment){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 36.0),
            child: Row(
              children: <Widget>[
                FloatingActionButton(
                  key: Key('rotate_ccw'),
                  backgroundColor: DynamicTheme.of(context).data.neutralActionButtonColor,
                  onPressed: (){
                    _selectedEquipment.forEach((FactoryEquipmentModel fem){
                      fem.direction = Direction.values[(fem.direction.index + 1) % Direction.values.length];
                    });
                  },
                  child: Icon(Icons.rotate_right, color: DynamicTheme.of(context).data.neutralActionIconColor,),
                ),
                SizedBox(width: 12.0,),
                FloatingActionButton(
                  key: Key('rotate_cw'),
                  backgroundColor: DynamicTheme.of(context).data.neutralActionButtonColor,
                  onPressed: (){
                    _selectedEquipment.forEach((FactoryEquipmentModel fem){
                      fem.direction = Direction.values[(fem.direction.index - 1) % Direction.values.length];
                    });
                  },
                  child: Icon(Icons.rotate_left, color: DynamicTheme.of(context).data.neutralActionIconColor,),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FloatingActionButton(
                  key: Key('move_fab'),
                  backgroundColor: DynamicTheme.of(context).data.neutralActionButtonColor,
                  onPressed: (){
                    _bloc.copyMode = _bloc.copyMode == CopyMode.move ? CopyMode.copy : CopyMode.move;
                  },
                  child: Icon((_bloc.copyMode == CopyMode.move) ? Icons.content_cut : Icons.content_copy, color: DynamicTheme.of(context).data.neutralActionIconColor,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FloatingActionButton(
                  key: Key('delete_fab'),
                  backgroundColor:  DynamicTheme.of(context).data.negativeActionButtonColor,
                  onPressed: (){
                    _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList().forEach(_bloc.removeEquipment);
                  },
                  child: Icon(Icons.clear, color:  DynamicTheme.of(context).data.negativeActionIconColor,),
                ),
              ),
            ],
          ),
        ],
      );
    }

    final FactoryEquipmentModel _equipment = _bloc.equipment.firstWhere((FactoryEquipmentModel fe) => _bloc.selectedTiles.first.x == fe.coordinates.x && _bloc.selectedTiles.first.y == fe.coordinates.y, orElse: () => null);

    if(_equipment == null){
      return FloatingActionButton(
        key: Key('build_fab'),
        backgroundColor:  DynamicTheme.of(context).data.positiveActionButtonColor,
        onPressed: (){
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context){
              return BuildEquipmentWidget(_bloc);
            }
          );
        },
        child: Icon(Icons.build, color: DynamicTheme.of(context).data.neutralActionIconColor,),
      );
    }else{
      bool _isBasic = _equipment.type == EquipmentType.portal || _equipment.type == EquipmentType.roller || _equipment.type == EquipmentType.freeRoller || _equipment.type == EquipmentType.wire_bender || _equipment.type == EquipmentType.cutter || _equipment.type == EquipmentType.hydraulic_press || _equipment.type == EquipmentType.melter;
      Widget _showModify = _isBasic ? SizedBox.shrink() : Row(
        children: <Widget>[
          SizedBox(width: 12.0,),
          FloatingActionButton(
            key: Key('info_fab'),
            backgroundColor: DynamicTheme.of(context).data.modifyActionButtonColor,
            onPressed: (){
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context){
                  return StreamBuilder<GameUpdate>(
                    stream: _bloc.gameUpdate,
                    builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot) {
                      return InfoWindow(_bloc);
                    }
                  );
                }
              );
            },
            child: Icon(Icons.developer_mode, color: DynamicTheme.of(context).data.modifyActionIconColor,),
          ),
        ],
      );

      bool _isNotRotatable = _equipment.type == EquipmentType.portal || _equipment.type == EquipmentType.seller || _equipment.type == EquipmentType.freeRoller || _equipment.type == EquipmentType.rotatingFreeRoller;
      Widget _showRotate = !_isNotRotatable ? Container(
        padding: EdgeInsets.only(left: 36.0),
        child: Row(
          children: <Widget>[
            FloatingActionButton(
              key: Key('rotate_ccw'),
              backgroundColor: DynamicTheme.of(context).data.neutralActionButtonColor,
              onPressed: (){
                _selectedEquipment.forEach((FactoryEquipmentModel fem){
                  fem.direction = Direction.values[(fem.direction.index + 1) % Direction.values.length];
                });
              },
              child: Icon(Icons.rotate_right, color: DynamicTheme.of(context).data.neutralActionIconColor,),
            ),
            SizedBox(width: 12.0,),
            FloatingActionButton(
              key: Key('rotate_cw'),
              backgroundColor: DynamicTheme.of(context).data.neutralActionButtonColor,
              onPressed: (){
                _selectedEquipment.forEach((FactoryEquipmentModel fem){
                  fem.direction = Direction.values[(fem.direction.index - 1) % Direction.values.length];
                });
              },
              child: Icon(Icons.rotate_left, color: DynamicTheme.of(context).data.neutralActionIconColor,),
            ),
          ],
        ),
      ) : SizedBox.shrink();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _showRotate,
          Row(
            children: <Widget>[
              FloatingActionButton(
                key: Key('move_fab'),
                backgroundColor: DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: (){
                  _bloc.copyMode = _bloc.copyMode == CopyMode.move ? CopyMode.copy : CopyMode.move;
                },
                child: Icon((_bloc.copyMode == CopyMode.move) ? Icons.content_cut : Icons.content_copy, color: DynamicTheme.of(context).data.neutralActionIconColor,),
              ),
              SizedBox(width: 12.0,),
              FloatingActionButton(
                key: Key('delete_fab'),
                backgroundColor:  DynamicTheme.of(context).data.negativeActionButtonColor,
                onPressed: (){
                  _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList().forEach(_bloc.removeEquipment);

                  if(_bloc.selectedTiles.length > 1){
                    _bloc.selectedTiles.clear();
                  }
                },
                child: Icon(Icons.clear, color:  DynamicTheme.of(context).data.negativeActionIconColor,),
              ),
              _showModify
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context){
    _bloc ??= GameBloc();

    return StreamBuilder<GameUpdate>(
      stream: _bloc.gameUpdate,
      builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot){
        final List<FactoryEquipmentModel> _selectedEquipment = _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList();

        return Scaffold(
          key: _key,
          drawer: _showFloors(),
          endDrawer: _showSettings(),
//          floatingActionButton: _showFab(),
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
                    child: Text('${_bloc.frameRate}',
                      style: Theme.of(context).textTheme.headline.copyWith(color: DynamicTheme.of(context).data.textColor, fontWeight: FontWeight.w200),
                    ),
                  ),
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(
                      height: 80.0,
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
                                  onTap: (){
                                    _key.currentState.openDrawer();
                                  },
                                  child: Icon(Icons.menu,
                                    color: DynamicTheme.of(context).data.textColor,
                                  ),
                                ),
                                Text(_bloc.floor,
                                  style: Theme.of(context).textTheme.title.copyWith(color: DynamicTheme.of(context).data.textColor),
                                ),
                                InkWell(
                                  onTap: (){
                                    _key.currentState.openEndDrawer();
                                  },
                                  child: Icon(Icons.settings,
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
                              width: MediaQuery.of(context).size.width  * _bloc.progress,
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
      }
    );
  }
}