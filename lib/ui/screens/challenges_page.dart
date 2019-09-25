import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_ticker.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/build_equipment_widget.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/crafter_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/dispenser_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/selected_object_footer.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/selected_object_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/seller_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/sorter_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/splitter_options.dart';
import 'package:hive/hive.dart';

class ChallengesListPage extends StatelessWidget {
  ChallengesListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (BuildContext context, int i){
                return Divider(height: 0.0);
              },
              itemBuilder: (BuildContext context, int i){
                return Container(
                  height: 120.0,
                  child: Stack(
                    children: <Widget>[
                      FutureBuilder<Box>(
                        future: Hive.openBox('challenge_$i'),
                        builder: (BuildContext context, AsyncSnapshot<Box> snapshot) {
                          return Positioned(
                            right: 0.0,
                            child: Container(
                              height: 120.0,
                              width: 12.0,
                              color: !snapshot.hasData ? Colors.grey : (snapshot.data?.get('did_complete') ?? false) ? Colors.green : Colors.yellow,
                            ),
                          );
                        }
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: ListTile(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute<void>(
                              builder: (BuildContext context) => ChallengesPage(loadChallenge: i,)
                            ));
                          },
                          title: Text('Challenge ${i + 1}',
                            style: Theme.of(context).textTheme.title,
                          ),
                          subtitle: Text('You have to use the space given to you, and build production line that will output ${
                            i == 0 ? '2 Washing machines' :
                            i == 1 ? '1 Air conditioner' :
                            i == 2 ? '1 Light bulb' :
                            i == 3 ? '1 Engine' : '0.6 Railway'
                          } per tick.',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Text('All challenges were designed by Elomavi on Discord!')
        ],
      ),
    );
  }
}

class ChallengesPage extends StatefulWidget {
  ChallengesPage({Key key, this.loadChallenge = 0}) : super(key: key);

  int loadChallenge;

  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> with SingleTickerProviderStateMixin{
  ChallengesBloc _bloc;
  GlobalKey<ScaffoldState> _key = GlobalKey();


   @override
   void dispose(){
     _bloc.dispose();
     super.dispose();
   }

  Widget _showSettings(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: Colors.white,
      padding: const EdgeInsets.all(12.0),
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
              Text('Tick speed: ${_bloc.gameSpeed} ms'),
              FloatingActionButton(
                onPressed: _bloc.decreaseGameSpeed,
                child: Icon(Icons.add),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Show arrows'),
            subtitle: Text('Visual representation on equipment'),
            onChanged: (bool value){
              setState(() {
                _bloc.showArrows = value;
              });
            },
            value: _bloc.showArrows,
          ),
          SizedBox(height: 28.0),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            child: RaisedButton(
              color: Colors.red,
              onPressed: _bloc.restart,
              child: Text('Restart challenge', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
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
      return FloatingActionButton(
        key: Key('delete_fab'),
        backgroundColor: Colors.red,
        onPressed: (){
          _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates) && fe.isMutable).toList().forEach(_bloc.removeEquipment);
        },
        child: Icon(Icons.clear),
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
    }else if(!_equipment.isMutable){
      return Container(
        color: Colors.white,
        child: InfoWindow(_bloc)
      );
    }else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _selectedEquipment.isEmpty ? SizedBox.shrink() : Container(
            padding: EdgeInsets.only(left: 36.0),
            child: Row(
              children: <Widget>[
                FloatingActionButton(
                  key: Key('rotate_ccw'),
                  backgroundColor: Colors.blue.shade700,
                  onPressed: (){
                    _selectedEquipment.where((FactoryEquipmentModel fem) => fem.isMutable).forEach((FactoryEquipmentModel fem){
                      fem.direction = Direction.values[(fem.direction.index + 1) % Direction.values.length];
                    });
                  },
                  child: Icon(Icons.rotate_right),
                ),
                SizedBox(width: 12.0,),
                FloatingActionButton(
                  key: Key('rotate_cw'),
                  backgroundColor: Colors.blue.shade700,
                  onPressed: (){
                    _selectedEquipment.where((FactoryEquipmentModel fem) => fem.isMutable).forEach((FactoryEquipmentModel fem){
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
              FloatingActionButton(
                key: Key('delete_fab'),
                backgroundColor: Colors.red,
                onPressed: (){
                  _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates) && fe.isMutable).toList().forEach(_bloc.removeEquipment);

                  if(_bloc.selectedTiles.length > 1){
                    _bloc.selectedTiles.clear();
                  }
                },
                child: Icon(Icons.clear),
              ),
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
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context){
    _bloc ??= ChallengesBloc(widget.loadChallenge);

    return StreamBuilder<GameUpdate>(
      stream: _bloc.gameUpdate,
      builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot){
        return Scaffold(
          key: _key,
          endDrawer: _showSettings(),
          floatingActionButton: _showFab(),
          body: GameProvider(
            bloc: _bloc,
            child: Stack(
              children: <Widget>[
                GameWidget(),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.black38,
                    child: Text('${_bloc.frameRate}',
                      style: Theme.of(context).textTheme.headline.copyWith(color: Colors.white, fontWeight: FontWeight.w200),
                    ),
                  ),
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Stack(
                      children: <Widget>[
                        AnimatedContainer(
                          duration: Duration(milliseconds: _bloc.gameSpeed),
                          curve: Curves.easeOutCubic,
                          color: Color.lerp(Colors.red, Colors.green, _bloc.complete).withOpacity(_bloc.complete == 1.0 ? 0.9 : 0.6),
                          height: 110.0,
                          width: MediaQuery.of(context).size.width * _bloc.complete,
                        ),
                        Container(
                          height: 110.0,
                          color: Colors.black38,
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          InkWell(
                                            onTap: (){
                                              Navigator.pop(context);
                                            },
                                            child: Icon(Icons.arrow_back_ios,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(_bloc.floor,
                                                style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
                                              ),
                                              Text(_bloc.getChallengeGoalDescription(),
                                                style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),
                                              ),
                                              Text('Current production: ${(_bloc.complete * _bloc.challengeGoal.values.first).toStringAsFixed(2)}',
                                                style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: (){
                                              _key.currentState.openEndDrawer();
                                            },
                                            child: Icon(Icons.settings,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: MediaQuery.of(context).size.width  * _bloc.progress,
                                  height: 4.0,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class InfoWindow extends StatelessWidget {
  InfoWindow(this._bloc, {Key key}) : super(key: key);

  final ChallengesBloc _bloc;

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
            Text('Multiple selected', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline.copyWith(color: Colors.black26, fontWeight: FontWeight.w900)),

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
        break;
    }

    if(_equipment.isMutable){
      _options.add(_showRotationOptions());
    }

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