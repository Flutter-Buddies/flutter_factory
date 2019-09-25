import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dark_game_theme.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/light_game_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_ticker.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/build_equipment_widget.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/crafter_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/dispenser_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/free_roller_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/selected_object_footer.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/selected_object_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/seller_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/sorter_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/splitter_options.dart';

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
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        width: MediaQuery.of(context).size.width * 0.8,
        color: ThemeProvider.of(context).floorColor.withOpacity(0.8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(height: 40.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _bloc.increaseGameSpeed,
                  child: Icon(Icons.remove),
                ),
                Text('Tick speed: ${_bloc.gameSpeed} ms', style: Theme.of(context).textTheme.subtitle.copyWith(color: DynamicTheme.of(context).data.textColor)),
                FloatingActionButton(
                  onPressed: _bloc.decreaseGameSpeed,
                  child: Icon(Icons.add),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Show arrows', style: Theme.of(context).textTheme.subtitle.copyWith(color: DynamicTheme.of(context).data.textColor),),
              subtitle: Text('Visual representation on equipment', style: Theme.of(context).textTheme.caption.copyWith(color: DynamicTheme.of(context).data.textColor),),
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
                    color: Colors.green.shade400,
                    onPressed: (){
                      _bloc.equipment.where((FactoryEquipmentModel fem) => fem is Dispenser).map<Dispenser>((FactoryEquipmentModel fem) => fem).forEach((Dispenser d){
                        d.isWorking = true;
                      });
                    },
                    child: Text('Turn on all dispensers', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
                  ),
                ),
                SizedBox(height: 8.0,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60.0,
                  child: RaisedButton(
                    color: Colors.red.shade400,
                    onPressed: (){
                      _bloc.equipment.where((FactoryEquipmentModel fem) => fem is Dispenser).map<Dispenser>((FactoryEquipmentModel fem) => fem).forEach((Dispenser d){
                        d.isWorking = false;
                      });
                    },
                    child: Text('Turn off all dispensers', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80.0,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: DynamicTheme.of(context).brightness == Brightness.light,
                    onChanged: (bool value){
                      DynamicTheme.of(context).setBrightness(value ? Brightness.light : Brightness.dark);
                    },
                    title: Text('Theme', style: Theme.of(context).textTheme.subtitle.copyWith(color: DynamicTheme.of(context).data.textColor)),
                    subtitle: Text(DynamicTheme.of(context).brightness == Brightness.light ? 'Light' : 'Dark', style: Theme.of(context).textTheme.caption.copyWith(color: DynamicTheme.of(context).data.textColor)),
                  )
                ),
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text('Machines: ${_bloc.equipment.length}', style: Theme.of(context).textTheme.caption.copyWith(color: DynamicTheme.of(context).data.textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                  Text('Materials: ${_bloc.material.length}', style: Theme.of(context).textTheme.caption.copyWith(color: DynamicTheme.of(context).data.textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                  Text('Excess Materials: ${_bloc.getExcessMaterial.length}', style: Theme.of(context).textTheme.caption.copyWith(color: DynamicTheme.of(context).data.textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                  Text('FPT: ${_bloc.frameRate}', style: Theme.of(context).textTheme.caption.copyWith(color: DynamicTheme.of(context).data.textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
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
                child: Text('Vaporize all material on this floor', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.red, fontWeight: FontWeight.w400),),
              ),
            ),
            SizedBox(height: 28.0),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 80.0,
              child: RaisedButton(
                color: Colors.red,
                onPressed: _bloc.clearLine,
                child: Text('CLEAR LINE', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showFloors(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: Colors.white,
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
                  backgroundColor: Colors.blue,
                  onPressed: (){
                    _selectedEquipment.forEach((FactoryEquipmentModel fem){
                      fem.direction = Direction.values[(fem.direction.index + 1) % Direction.values.length];
                    });
                  },
                  child: Icon(Icons.rotate_right),
                ),
                SizedBox(width: 12.0,),
                FloatingActionButton(
                  key: Key('rotate_cw'),
                  backgroundColor: Colors.blue,
                  onPressed: (){
                    _selectedEquipment.forEach((FactoryEquipmentModel fem){
                      fem.direction = Direction.values[(fem.direction.index - 1) % Direction.values.length];
                    });
                  },
                  child: Icon(Icons.rotate_left),
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
                  backgroundColor: Colors.blue,
                  onPressed: (){
                    _bloc.copyMode = _bloc.copyMode == CopyMode.move ? CopyMode.copy : CopyMode.move;
                  },
                  child: Icon((_bloc.copyMode == CopyMode.move) ? Icons.content_cut : Icons.content_copy),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FloatingActionButton(
                  key: Key('delete_fab'),
                  backgroundColor: Colors.red,
                  onPressed: (){
                    _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList().forEach(_bloc.removeEquipment);
                  },
                  child: Icon(Icons.clear),
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
        backgroundColor: Colors.green,
        onPressed: (){
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context){
              return BuildEquipmentWidget(_bloc);
            }
          );
        },
        child: Icon(Icons.build),
      );
    }else{
      bool _isBasic = _equipment.type == EquipmentType.roller || _equipment.type == EquipmentType.freeRoller || _equipment.type == EquipmentType.wire_bender || _equipment.type == EquipmentType.cutter || _equipment.type == EquipmentType.hydraulic_press || _equipment.type == EquipmentType.melter || _equipment.type == EquipmentType.rotatingFreeRoller;
      Widget _showModify = _isBasic ? SizedBox.shrink() : Row(
        children: <Widget>[
          SizedBox(width: 12.0,),
          FloatingActionButton(
            key: Key('info_fab'),
            backgroundColor: Colors.yellow.shade700,
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
            child: Icon(Icons.developer_mode),
          ),
        ],
      );

      bool _isNotRotatable = _equipment.type == EquipmentType.seller || _equipment.type == EquipmentType.freeRoller || _equipment.type == EquipmentType.rotatingFreeRoller;
      Widget _showRotate = !_isNotRotatable ? Container(
        padding: EdgeInsets.only(left: 36.0),
        child: Row(
          children: <Widget>[
            FloatingActionButton(
              key: Key('rotate_ccw'),
              backgroundColor: Colors.blue,
              onPressed: (){
                _selectedEquipment.forEach((FactoryEquipmentModel fem){
                  fem.direction = Direction.values[(fem.direction.index + 1) % Direction.values.length];
                });
              },
              child: Icon(Icons.rotate_right),
            ),
            SizedBox(width: 12.0,),
            FloatingActionButton(
              key: Key('rotate_cw'),
              backgroundColor: Colors.blue,
              onPressed: (){
                _selectedEquipment.forEach((FactoryEquipmentModel fem){
                  fem.direction = Direction.values[(fem.direction.index - 1) % Direction.values.length];
                });
              },
              child: Icon(Icons.rotate_left),
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
                backgroundColor: Colors.blue,
                onPressed: (){
                  _bloc.copyMode = _bloc.copyMode == CopyMode.move ? CopyMode.copy : CopyMode.move;
                },
                child: Icon((_bloc.copyMode == CopyMode.move) ? Icons.content_cut : Icons.content_copy),
              ),
              SizedBox(width: 12.0,),
              FloatingActionButton(
                key: Key('delete_fab'),
                backgroundColor: Colors.red,
                onPressed: (){
                  _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList().forEach(_bloc.removeEquipment);

                  if(_bloc.selectedTiles.length > 1){
                    _bloc.selectedTiles.clear();
                  }
                },
                child: Icon(Icons.clear),
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
          floatingActionButton: _showFab(),
          body: Theme(
            data: DynamicTheme.of(context).brightness == Brightness.light ? ThemeData.light() : ThemeData.dark(),
            child: GameProvider(
              bloc: _bloc,
              child: Stack(
                children: <Widget>[
                  GameWidget(),
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
          ),
        );
      }
    );
  }
}

class InfoWindow extends StatelessWidget {
  InfoWindow(this._bloc, {Key key}) : super(key: key);

  final GameBloc _bloc;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _options = <Widget>[];
    final List<FactoryEquipmentModel> _selectedEquipment = _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList();
    final bool _isSameEquipment = _selectedEquipment.every((FactoryEquipmentModel fe) => fe.type == _selectedEquipment.first.type) && _selectedEquipment.length == _bloc.selectedTiles.length;

    if(_bloc.selectedTiles.length > 1 && _selectedEquipment.isNotEmpty && !_isSameEquipment){
      return Container(
        height: 300.0,
        margin: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Multiple selected', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.w900)),

            SizedBox(height: 48.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  onPressed: (){
                    print('Copy');
                  },
                  child: Text('Copy'),
                ),
                FlatButton(
                  onPressed: (){
                    print('Cut');
                  },
                  child: Text('Cut'),
                ),
                FlatButton(
                  onPressed: (){
                    print('Delete');
                  },
                  child: Text('Delete'),
                ),
              ],
            ),

            RaisedButton(
              onPressed: (){
                print('Delete');

                _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList().forEach(_bloc.removeEquipment);

                _bloc.selectedTiles.clear();
                _bloc.changeWindow(GameWindows.buy);
              },
              color: Colors.red,
              child: Container(
                margin: const EdgeInsets.all(12.0),
                child: Text('Delete', style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),),
              ),
            ),
          ],
        ),
      );
    }

    final FactoryEquipmentModel _equipment = _bloc.equipment.firstWhere((FactoryEquipmentModel fe) => _bloc.selectedTiles.first.x == fe.coordinates.x && _bloc.selectedTiles.first.y == fe.coordinates.y, orElse: () => null);

    Widget _buildNoEquipment(){
      return BuildEquipmentWidget(_bloc);
    }

    Widget _showSellerOptions(){
      return SellerInfo(equipment: _equipment);
    }

    Widget _showSelectedInfo(){
      return SelectedObjectInfoWidget(equipment: _equipment, progress: _bloc.progress);
    }

    Widget _showDispenserOptions(){
      return DispenserOptionsWidget(dispenser: _selectedEquipment.where((FactoryEquipmentModel fe) => fe is Dispenser).map<Dispenser>((FactoryEquipmentModel fe) => fe).toList(), progress: _bloc.progress);
    }

    Widget _showSplitterOptions(){
      return SplitterOptionsWidget(splitter: _equipment);
    }

    Widget _showSorterOptions(){
      return SorterOptionsWidget(sorter: _equipment);
    }

    Widget _showCrafterOptions(){
      return CrafterOptionsWidget(crafter: _selectedEquipment.where((FactoryEquipmentModel fe) => fe is Crafter).map<Crafter>((FactoryEquipmentModel fe) => fe).toList(), progress: _bloc.progress);
    }

    Widget _showRotationOptions(){
      return SelectedObjectFooter(_bloc, equipment: _selectedEquipment);
    }

    if(_equipment == null){
      return _buildNoEquipment();
    }

    _options.add(_showSelectedInfo());

    switch(_equipment.type){
      case EquipmentType.dispenser:
        _options.add(_showDispenserOptions());
        break;
      case EquipmentType.roller:
        break;
      case EquipmentType.crafter:
        _options.add(_showCrafterOptions());
        break;
      case EquipmentType.splitter:
        _options.add(_showSplitterOptions());
        break;
      case EquipmentType.sorter:
        _options.add(_showSorterOptions());
        break;
      case EquipmentType.seller:
        _options.add(_showSellerOptions());
        break;
      case EquipmentType.hydraulic_press:
        break;
      case EquipmentType.wire_bender:
        break;
      case EquipmentType.cutter:
        break;
      case EquipmentType.melter:
        break;
      case EquipmentType.freeRoller:
        break;
      case EquipmentType.rotatingFreeRoller:
        _options.add(FreeRollerInfo(equipment: _equipment));
        break;
    }

    _options.add(_showRotationOptions());

    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: _options,
        ),
      ),
    );
  }
}