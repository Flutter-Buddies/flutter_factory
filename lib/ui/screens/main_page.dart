import 'package:flutter/material.dart';
import 'package:flutter_factory/game/equipment/crafter.dart';
import 'package:flutter_factory/game/equipment/dispenser.dart';
import 'package:flutter_factory/game/equipment/sorter.dart';
import 'package:flutter_factory/game/equipment/splitter.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/widgets/backdrop.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_ticker.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';

class MainPage extends StatelessWidget {
  MainPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackdropHolder(),
    );
  }
}

class BackdropHolder extends StatefulWidget {
  BackdropHolder({Key key}) : super(key: key);

  @override
  _BackdropHolderState createState() => new _BackdropHolderState();
}

class _BackdropHolderState extends State<BackdropHolder> with SingleTickerProviderStateMixin{
  double _openValue = 0.0;
  GameBloc _bloc;
  AnimationController _animationController;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.addListener((){
      setState(() {
        _openValue = _animationController.value;
      });
    });
  }

  void _toggleFrontLayer() {
    final AnimationStatus status = _animationController.status;
    final bool isOpen = status == AnimationStatus.completed || status == AnimationStatus.forward;
    _animationController.fling(velocity: isOpen ? -2.0 : 2.0);
  }

  @override
  Widget build(BuildContext context) {
    _bloc ??= GameBloc();

    return Backdrop(
      controller: _animationController,
      backTitle: Text('Customize', style: Theme.of(context).textTheme.title),
      frontTitle: Text('Game', style: Theme.of(context).textTheme.title),
      backLayer: GameProvider(
        bloc: _bloc,
        child: Stack(
          children: <Widget>[
            GameWidget(),
            GameTicker(),
          ],
        ),
      ),
      frontLayer: InfoWindow(_bloc, _openValue, _toggleFrontLayer, key: _key,),
    );
  }
}

class InfoWindow extends StatelessWidget {
  InfoWindow(this._bloc, this.open, this.toggleDrawer, {Key key}) : super(key: key);

  final GameBloc _bloc;
  final double open;
  final VoidCallback toggleDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: StreamBuilder<GameUpdate>(
        stream: _bloc.gameUpdate,
        builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot){
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned(
                top: 0.0,
                height: 80.0,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: InkWell(
                        onTap: (){
                          if(_bloc.currentWindow == GameWindows.buy){
                            toggleDrawer();
                          }else{
                            if(open == 0){
                              toggleDrawer();
                            }

                            _bloc.changeWindow(GameWindows.buy);
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: SizedBox.expand(child: Icon(Icons.add_shopping_cart, color: _bloc.currentWindow == GameWindows.buy ? Colors.blue : Colors.grey)),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.blue, width: _bloc.currentWindow == GameWindows.buy ? 4.0 : 0.0)
                            )
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: InkWell(
                        onTap: (){
                          if(_bloc.currentWindow == GameWindows.settings){
                            toggleDrawer();
                          }else{
                            if(open == 0){
                              toggleDrawer();
                            }

                            _bloc.changeWindow(GameWindows.settings);
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: SizedBox.expand(child: Icon(Icons.settings, color: _bloc.currentWindow == GameWindows.settings ? Colors.blue : Colors.grey)),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.blue, width: _bloc.currentWindow == GameWindows.settings ? 4.0 : 0.0)
                            )
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _getSelectedWindow(context)
            ],
          );
        },
      ),
    );
  }

  Widget _getSelectedWindow(BuildContext context){
    Widget _child;

    if(_bloc.currentWindow == GameWindows.settings){
      _child = _showSettings();
    }else{
      _child = _showModify(context);
    }

    return Positioned(
      top: 80.0,
      width: MediaQuery.of(context).size.width,
      child: Container(
        child: _child,
      ),
    );
  }

  Widget _showModify(BuildContext context){
    final List<Widget> _options = <Widget>[];

    if(_bloc.selectedTiles.isEmpty){
      return Center(
        child: Text('Nothing selected!'),
      );
    }

    final FactoryEquipment _equipment = _bloc.equipment.firstWhere((FactoryEquipment fe) => _bloc.selectedTiles.first.x == fe.coordinates.x && _bloc.selectedTiles.first.y == fe.coordinates.y, orElse: () => null);

    Widget _buildNoEquipment(){
      return Container(
        height: 320.0,
        margin: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Build equipment:'),
                    DropdownButton<EquipmentType>(
                      onChanged: (EquipmentType et){
                        _bloc.buildSelectedEquipmentType = et;
                      },
                      value: _bloc.buildSelectedEquipmentType,
                      items: EquipmentType.values.map((EquipmentType et){
                        return DropdownMenuItem<EquipmentType>(
                          value: et,
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: CustomPaint(
                                  painter: ObjectPainter(
                                    _bloc.progress,
                                    equipment: _bloc.previewEquipment(et),
                                    objectSize: 32.0
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(12.0),
                                child: Text('${et.toString().replaceAll('EquipmentType.', '').toUpperCase()}')
                              ),
                            ],
                          ),
                        );
                      }).toList()
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Build direction:'),
                    DropdownButton<Direction>(
                      onChanged: (Direction et){
                        _bloc.buildSelectedEquipmentDirection = et;
                      },
                      value: _bloc.buildSelectedEquipmentDirection,
                      items: Direction.values.map((Direction et){
                        return DropdownMenuItem<Direction>(
                          value: et,
                          child: Container(
                            margin: const EdgeInsets.all(12.0),
                            child: Text('${et.toString().replaceAll('Direction.', '').toUpperCase()}')
                          ),
                        );
                      }).toList()
                    ),
                  ],
                ),
              ],
            ),

            Container(
              width: MediaQuery.of(context).size.width,
              height: 80.0,
              child: RaisedButton(
                color: Colors.blue,
                onPressed: _bloc.buildSelected,
                child: Text('BUILD', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
              ),
            )
          ],
        ),
      );
    }

    Widget _showSelectedInfo(){
      return Container(
        height: 80.0,
        margin: EdgeInsets.symmetric(vertical: 36.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36.0),
                  child: CustomPaint(
                    painter: ObjectPainter(
                      _bloc.progress,
                      equipment: _equipment
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                  child: Text('${_equipment.type.toString().replaceAll('EquipmentType.', '').toUpperCase()}'),
                ),
              ],
            ),
            Divider(),
          ],
        ),
      );
    }

    Widget _showDispenserOptions(){
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Produce material:'),
                DropdownButton<FactoryMaterialType>(
                  value: (_equipment as Dispenser).dispenseMaterial,
                  onChanged: (FactoryMaterialType fmt){
                    (_equipment as Dispenser).dispenseMaterial = fmt;
                  },
                  items: FactoryMaterialType.values.where(FactoryMaterial.isRaw).map((FactoryMaterialType fmt){
                    return DropdownMenuItem<FactoryMaterialType>(
                      value: fmt,
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: CustomPaint(
                              painter: ObjectPainter(
                                _bloc.progress,
                                material: FactoryMaterial.getFromType(fmt)
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 12.0),
                            child: Text('${fmt.toString().replaceAll('FactoryMaterialType.', '').toUpperCase()}'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
            SizedBox(height: 28.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Produce time:'),
                DropdownButton<int>(
                  value: _equipment.tickDuration,
                  onChanged: (int fmt){
                    _equipment.tickDuration = fmt;
                  },
                  items: List<int>.generate(8, (int i) => i + 1).map((int fmt){
                    return DropdownMenuItem<int>(
                      value: fmt,
                      child: Text('${fmt.toString()}'),
                    );
                  }).toList(),
                )
              ],
            ),
            SizedBox(height: 28.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Produce amount:'),
                DropdownButton<int>(
                  value: (_equipment as Dispenser).dispenseAmount,
                  onChanged: (int fmt){
                    (_equipment as Dispenser).dispenseAmount = fmt;
                  },
                  items: List<int>.generate(8, (int i) => i + 1).map((int fmt){
                    return DropdownMenuItem<int>(
                      value: fmt,
                      child: Text('${fmt.toString()}'),
                    );
                  }).toList(),
                )
              ],
            ),
            SizedBox(height: 28.0),
          ],
        ),
      );
    }

    Widget _showSplitterOptions(){
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: <Widget>[
            Text('Split:'),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: (_equipment as Splitter).directions.map((Direction d){
                return ActionChip(
                  label: Text('${d.toString().replaceAll('Direction.', '').toUpperCase()}'),
                  onPressed: (){
                    (_equipment as Splitter).directions.remove(d);
                  },
                );
              }).toList(),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Direction.values.map((Direction d){
                if(d == Direction.values[(_equipment.direction.index + 2) % Direction.values.length]){
                  return Container(
                    height: 120.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        ChoiceChip(
                          label: Text('${d.toString().replaceAll('Direction.', '').toUpperCase()}'),
                          selected: false,
                        ),
                        FlatButton(
                          onPressed: null,
                          child: Text('EntryPoint'),
                        )
                      ],
                    ),
                  );
                }

                return Container(
                  height: 120.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ActionChip(
                        label: Text('${d.toString().replaceAll('Direction.', '').toUpperCase()} - (${(_equipment as Splitter).directions.where((Direction _d) => _d == d).length})'),
                        onPressed: (){

                        },
                      ),
                      FlatButton.icon(
                        onPressed: (){
                          (_equipment as Splitter).directions.add(d);
                        },
                        label: Text('Add'),
                        icon: Icon(Icons.add),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    Widget _showSorterOptions(){
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: <Widget>[
            Text('Sort:'),
            Column(
              children: Direction.values.map((Direction d){
                if(d == Direction.values[(_equipment.direction.index + 2) % Direction.values.length]){
                  return Container(
                    height: 80.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${d.toString().replaceAll('Direction.', '').toUpperCase()}'),
                        Text('Entry point')
                      ],
                    ),
                  );
                }

                List<FactoryMaterialType> _filteredForDirection = (_equipment as Sorter).directions.keys.where((FactoryMaterialType fmt) => (_equipment as Sorter).directions[fmt] == d).toList();

                return Container(
                  height: 120.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('${d.toString().replaceAll('Direction.', '').toUpperCase()} - (${(_equipment as Sorter).directions.values.where((Direction _d) => _d == d).length})'),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _filteredForDirection.map((FactoryMaterialType fmt){
                          return ActionChip(
                            label: Row(
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: CustomPaint(
                                    painter: ObjectPainter(
                                      _bloc.progress,
                                      material: FactoryMaterial.getFromType(fmt)
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 12.0),
                                  child: Text('${fmt.toString().replaceAll('FactoryMaterialType.', '').toUpperCase()}'),
                                ),
                              ],
                            ),
                            onPressed: (){
                              (_equipment as Sorter).directions.remove(fmt);
                            },
                          );
                        }).toList(),
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.add),
                        onSelected: (FactoryMaterialType fmt){
                          (_equipment as Sorter).directions.addAll(<FactoryMaterialType, Direction>{
                            fmt: d
                          });
                        },
                        itemBuilder: (BuildContext context){
                          return FactoryMaterialType.values.where((FactoryMaterialType fmt) => !(_equipment as Sorter).directions.containsKey(fmt) || (_equipment as Sorter).directions[fmt] != d).map((FactoryMaterialType fmt){
                            return PopupMenuItem<FactoryMaterialType>(
                              value: fmt,
                              child: Text('${fmt.toString().replaceAll('FactoryMaterialType.', '').toUpperCase()}'),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    Widget _showCrafterOptions(){
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Craft queue:'),
                Column(
                  children: FactoryMaterialType.values.map((FactoryMaterialType fmt){
                    return Chip(
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: CustomPaint(
                                  painter: ObjectPainter(
                                    _bloc.progress,
                                    material: FactoryMaterial.getFromType(fmt)
                                  ),
                                ),
                              ),
                              Text('${fmt.toString().replaceAll('FactoryMaterialType.', '').toUpperCase()}'),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 4.0),
                            height: 26.0,
                            width: 96.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.grey.shade800
                            ),
                            child: Center(child: Text('${(_equipment as Crafter).objects.where((FactoryMaterial _fm) => _fm.type == fmt).length}', style: TextStyle(color: Colors.white),))
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
            SizedBox(height: 28.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Craft recipe:'),
                DropdownButton<FactoryMaterialType>(
                  value: (_equipment as Crafter).craftMaterial,
                  onChanged: (FactoryMaterialType fmt){
                    (_equipment as Crafter).changeRecipe(fmt);
                  },
                  items: FactoryMaterialType.values.where((FactoryMaterialType fmt) => !FactoryMaterial.isRaw(fmt)).map((FactoryMaterialType fmt){
                    return DropdownMenuItem<FactoryMaterialType>(
                      value: fmt,
                      child: Container(
                        margin: const EdgeInsets.all(12.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: CustomPaint(
                                painter: ObjectPainter(
                                  _bloc.progress,
                                  material: FactoryMaterial.getFromType(fmt)
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 12.0),
                              child: Text('${fmt.toString().replaceAll('FactoryMaterialType.', '').toUpperCase()}'),
                            ),
                          ],
                        )
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
            SizedBox(height: 28.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Craft speed:'),
                DropdownButton<int>(
                  value: _equipment.tickDuration,
                  onChanged: (int fmt){
                    _equipment.tickDuration = fmt;
                  },
                  items: List<int>.generate(8, (int i) => i + 1).map((int fmt){
                    return DropdownMenuItem<int>(
                      value: fmt,
                      child: Container(
                        margin: const EdgeInsets.all(12.0),
                        child: Text('${fmt.toString().replaceAll('FactoryMaterialType.', '').toUpperCase()}')
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
            SizedBox(height: 28.0),
          ],
        ),
      );
    }

    Widget _showRotationOptions(){
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: <Widget>[
            Container(
              height: 80.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Rotate:'),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: FloatingActionButton(
                            child: Icon(Icons.rotate_left),
                            onPressed: (){
                              _equipment.direction = Direction.values[(_equipment.direction.index - 1) % Direction.values.length];
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: FloatingActionButton(
                            child: Icon(Icons.rotate_right),
                            onPressed: (){
                              _equipment.direction = Direction.values[(_equipment.direction.index + 1) % Direction.values.length];
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 28.0),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 80.0,
              child: RaisedButton(
                color: Colors.red,
                onPressed: () => _bloc.equipment.remove(_equipment),
                child: Text('DELETE', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
              ),
            ),
            SizedBox(height: 28.0),
          ],
        ),
      );
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
    }

    _options.add(_showRotationOptions());

    return Container(
      height: MediaQuery.of(context).size.height / 2 - 80.0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: _options,
        ),
      ),
    );
  }

  Widget _showSettings(){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                onPressed: _bloc.increaseGameSpeed,
                mini: true,
                child: Icon(Icons.remove),
              ),
              Text('Game speed: ${_bloc.gameSpeed}'),
              FloatingActionButton(
                onPressed: _bloc.decreaseGameSpeed,
                mini: true,
                child: Icon(Icons.add),
              ),
            ],
          ),

          Column(
            children: <Widget>[
              Text('Show arrows'),
              FloatingActionButton(
                onPressed: (){
                  _bloc.showArrows = !_bloc.showArrows;
                },
                mini: true,
                child: Icon(_bloc.showArrows ? Icons.visibility : Icons.visibility_off),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ObjectPainter extends CustomPainter{
  ObjectPainter(this.progress, {this.objectSize = 48.0, this.equipment, this.material});

  final FactoryMaterial material;
  final FactoryEquipment equipment;

  final double objectSize;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if(material != null){
      material.drawMaterial(Offset.zero, canvas, progress);
    }

    if(equipment != null){
      equipment.drawTrack(Offset.zero, canvas, objectSize, progress);
      equipment.drawMaterial(Offset.zero, canvas, objectSize, progress);
      equipment.drawEquipment(Offset.zero, canvas, objectSize, progress);
    }
  }

  @override
  bool shouldRepaint(ObjectPainter oldDelegate) {
    return oldDelegate.material != material || oldDelegate.equipment != equipment || oldDelegate.progress != progress || oldDelegate.objectSize != objectSize;
  }
}