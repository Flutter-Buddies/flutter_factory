import 'package:flutter/material.dart';
import 'package:flutter_factory/game/equipment/crafter.dart';
import 'package:flutter_factory/game/equipment/dispenser.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/widgets/backdrop.dart';
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
  Widget build(BuildContext context){
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

            StreamBuilder(
              stream: _bloc.gameUpdate,
              builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot){
                return Positioned(
                  top: 120.0,
                  right: 0.0,
                  child: Container(
                    color: Colors.black26,
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Machines: ${_bloc.equipment.length}', style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),),
                        Text('Materials: ${_bloc.material.length}', style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),),
                        Text('Excess Materials: ${_bloc.getExcessMaterial.length}', style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),),
                        Text('FPS: ${_bloc.frameRate}', style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),),
                      ],
                    ),
                  )
                );
              },
            ),
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
                          child: SizedBox.expand(child: Icon(Icons.edit, color: _bloc.currentWindow == GameWindows.buy ? Colors.blue : Colors.grey)),
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
                          child: SizedBox.expand(child: Icon(Icons.more_horiz, color: _bloc.currentWindow == GameWindows.settings ? Colors.blue : Colors.grey)),
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
      _child = _showSettings(context);
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
      return Container(
        height: 300.0,
        child: Center(
          child: Text('Nothing selected.', style: Theme.of(context).textTheme.headline.copyWith(color: Colors.black26, fontWeight: FontWeight.w900)),
        ),
      );
    }

    final List<FactoryEquipment> _selectedEquipment = _bloc.equipment.where((FactoryEquipment fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList();
    final bool _isSameEquipment = _selectedEquipment.every((FactoryEquipment fe) => fe.type == _selectedEquipment.first.type) && _selectedEquipment.length == _bloc.selectedTiles.length;

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

                _bloc.equipment.where((FactoryEquipment fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList().forEach(_bloc.removeEquipment);

                _bloc.changeWindow(GameWindows.buy);
              },
              color: Colors.red,
              child: Container(
                margin: const EdgeInsets.all(24.0),
                child: Text('Delete', style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),),
              ),
            ),
          ],
        ),
      );
    }

    final FactoryEquipment _equipment = _bloc.equipment.firstWhere((FactoryEquipment fe) => _bloc.selectedTiles.first.x == fe.coordinates.x && _bloc.selectedTiles.first.y == fe.coordinates.y, orElse: () => null);

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
      return DispenserOptionsWidget(dispenser: _selectedEquipment.where((FactoryEquipment fe) => fe is Dispenser).map<Dispenser>((FactoryEquipment fe) => fe).toList(), progress: _bloc.progress);
    }

    Widget _showSplitterOptions(){
      return SplitterOptionsWidget(splitter: _equipment);
    }

    Widget _showSorterOptions(){
      return SorterOptionsWidget(sorter: _equipment);
    }

    Widget _showCrafterOptions(){
      return CrafterOptionsWidget(crafter: _selectedEquipment.where((FactoryEquipment fe) => fe is Crafter).map<Crafter>((FactoryEquipment fe) => fe).toList(), progress: _bloc.progress);
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

  Widget _showSettings(BuildContext context){
    return Container(
      margin: const EdgeInsets.all(36.0),
      height: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                onPressed: _bloc.increaseGameSpeed,
                child: Icon(Icons.remove),
              ),
              Text('Tick speed: ${_bloc.gameSpeed}'),
              FloatingActionButton(
                onPressed: _bloc.decreaseGameSpeed,
                child: Icon(Icons.add),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          ),

          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                onPressed: (){
                  _bloc.changeFloor(0);
                },
                child: Text('Ground floor'),
              ),
              FlatButton(
                onPressed: (){
                  _bloc.changeFloor(1);
                },
                child: Text('First floor'),
              ),
              FlatButton(
                onPressed: (){
                  _bloc.changeFloor(2);
                },
                child: Text('Second floor'),
              ),
              FlatButton(
                onPressed: (){
                  _bloc.changeFloor(3);
                },
                child: Text('Secret floor'),
              ),
            ],
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
    );
  }
}