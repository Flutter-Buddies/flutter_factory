import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';

class SelectedObjectFooter extends StatelessWidget {
  SelectedObjectFooter(this._bloc, {@required this.equipment, Key key}) : super(key: key);

  final GameBloc _bloc;
  final List<FactoryEquipment> equipment;

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
                Text('Direction:'),
                Row(
                  children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.zero,
                      child: Text('←', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 24.0),),
                      onPressed: (){
                        equipment.forEach((FactoryEquipment fe){
                          fe.direction = Direction.west;
                        });
                      },
                    ),
                    FlatButton(
                      padding: EdgeInsets.zero,
                      child: Text('↑', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 24.0),),
                      onPressed: (){
                        equipment.forEach((FactoryEquipment fe){
                          fe.direction = Direction.south;
                        });
                      },
                    ),
                    FlatButton(
                      padding: EdgeInsets.zero,
                      child: Text('↓', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 24.0),),
                      onPressed: (){
                        equipment.forEach((FactoryEquipment fe){
                          fe.direction = Direction.north;
                        });
                      },
                    ),
                    FlatButton(
                      padding: EdgeInsets.zero,
                      child: Text('→', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 24.0),),
                      onPressed: (){
                        equipment.forEach((FactoryEquipment fe){
                          fe.direction = Direction.east;
                        });
                      },
                    ),
                  ],
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
              onPressed: (){
                equipment.forEach(_bloc.removeEquipment);
              },
              child: Text('DELETE', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
            ),
          ),
          SizedBox(height: 28.0),
        ],
      ),
    );
  }
}
