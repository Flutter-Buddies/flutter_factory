import 'package:flutter/material.dart';
import 'package:flutter_factory/game/equipment/splitter.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';

class SplitterOptionsWidget extends StatelessWidget {
  SplitterOptionsWidget({@required this.splitter, Key key}) : super(key: key);

  final Splitter splitter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: <Widget>[
          Text('Split:'),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: splitter.directions.map((Direction d){
              return ActionChip(
                label: Text('${d.toString().replaceAll('Direction.', '').toUpperCase()}'),
                onPressed: (){
                  splitter.directions.remove(d);
                },
              );
            }).toList(),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: Direction.values.map((Direction d){
              if(d == Direction.values[(splitter.direction.index + 2) % Direction.values.length]){
                return Container(
                  height: 120.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text('${d.toString().replaceAll('Direction.', '').toUpperCase()}'),
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
                    Text('${d.toString().replaceAll('Direction.', '').toUpperCase()}\n[${splitter.directions.where((Direction _d) => _d == d).length}]', textAlign: TextAlign.center,),
                    FlatButton.icon(
                      onPressed: (){
                        splitter.directions.add(d);
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
}
