import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';

class SplitterOptionsWidget extends StatelessWidget {
  SplitterOptionsWidget({@required this.splitter, Key key}) : super(key: key);

  final Splitter splitter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: Text('Split directions:')
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: splitter.directions.map((Direction d){
              return ActionChip(
                backgroundColor: Colors.grey.shade100,
                shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade400)),
                label: Text('${directionToString(d)}'),
                onPressed: (){
                  if(splitter.directions.length > 1){
                    splitter.directions.remove(d);
                  }
                },
              );
            }).toList(),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Add split direction: '),
              Flexible(
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FlatButton(
                        padding: EdgeInsets.zero,
                        child: Text('↑ [${splitter.directions.where((Direction _d) => _d == Direction.south).length}]', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                        onPressed: (){
                          splitter.directions.add(Direction.south);
                        },
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.zero,
                            child: Text('← [${splitter.directions.where((Direction _d) => _d == Direction.west).length}]', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                            onPressed: (){
                                splitter.directions.add(Direction.west);
                            },
                          ),
                          FlatButton(
                            padding: EdgeInsets.zero,
                            child: Text('→ [${splitter.directions.where((Direction _d) => _d == Direction.east).length}]', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                            onPressed: (){
                                splitter.directions.add(Direction.east);
                            },
                          ),
                        ],
                      ),
                      FlatButton(
                        padding: EdgeInsets.zero,
                        child: Text('↓ [${splitter.directions.where((Direction _d) => _d == Direction.north).length}]', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                        onPressed: (){
                            splitter.directions.add(Direction.north);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Divider(),
        ],
      ),
    );
  }
}
