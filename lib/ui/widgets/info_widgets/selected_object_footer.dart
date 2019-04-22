import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';

class SelectedObjectFooter extends StatelessWidget {
  SelectedObjectFooter(this._bloc, {@required this.equipment, Key key}) : super(key: key);

  final GameBloc _bloc;
  final FactoryEquipment equipment;

  @override
  Widget build(BuildContext context) {
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
                            equipment.direction = Direction.values[(equipment.direction.index - 1) % Direction.values.length];
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: FloatingActionButton(
                          child: Icon(Icons.rotate_right),
                          onPressed: (){
                            equipment.direction = Direction.values[(equipment.direction.index + 1) % Direction.values.length];
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
              onPressed: () => _bloc.equipment.remove(equipment),
              child: Text('DELETE', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
            ),
          ),
          SizedBox(height: 28.0),
        ],
      ),
    );
  }
}
