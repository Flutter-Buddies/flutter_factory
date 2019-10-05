import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';

class SplitterOptionsWidget extends StatelessWidget {
  SplitterOptionsWidget({@required this.splitter, Key key}) : super(key: key);

  final Splitter splitter;

  @override
  Widget build(BuildContext context) {
    splitter.directions.sort((Direction d, Direction dd) => d.index.compareTo(dd.index));

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
              Flexible(
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Material(
                            color: DynamicTheme.of(context).data.negativeActionButtonColor,
                            child: Container(
                              child: InkWell(
                                onTap: (){
                                  splitter.directions.remove(Direction.south);
                                },
                                child: Container(
                                  width: 56.0,
                                  height: 56.0,
                                  child: Icon(Icons.remove, color: DynamicTheme.of(context).data.negativeActionIconColor,),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text('↑\n[${splitter.directions.where((Direction _d) => _d == Direction.south).length}]', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                          ),
                          Material(
                            color: DynamicTheme.of(context).data.positiveActionButtonColor,
                            child: Container(
                              child: InkWell(
                                onTap: (){
                                  splitter.directions.add(Direction.south);
                                },
                                child: Container(
                                  width: 56.0,
                                  height: 56.0,
                                  child: Icon(Icons.add, color: DynamicTheme.of(context).data.positiveActionIconColor,),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.0,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Material(
                                color: DynamicTheme.of(context).data.negativeActionButtonColor,
                                child: Container(
                                  child: InkWell(
                                    onTap: (){
                                      splitter.directions.remove(Direction.west);
                                    },
                                    child: Container(
                                      width: 56.0,
                                      height: 56.0,
                                      child: Icon(Icons.remove, color: DynamicTheme.of(context).data.negativeActionIconColor,),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text('←\n[${splitter.directions.where((Direction _d) => _d == Direction.west).length}]', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                              ),
                              Material(
                                color: DynamicTheme.of(context).data.positiveActionButtonColor,
                                child: Container(
                                  child: InkWell(
                                    onTap: (){
                                      splitter.directions.add(Direction.west);
                                    },
                                    child: Container(
                                      width: 56.0,
                                      height: 56.0,
                                      child: Icon(Icons.add, color: DynamicTheme.of(context).data.positiveActionIconColor,),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 24.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Material(
                                color: DynamicTheme.of(context).data.negativeActionButtonColor,
                                child: Container(
                                  child: InkWell(
                                    onTap: (){
                                      splitter.directions.remove(Direction.east);
                                    },
                                    child: Container(
                                      width: 56.0,
                                      height: 56.0,
                                      child: Icon(Icons.remove, color: DynamicTheme.of(context).data.negativeActionIconColor,),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text('→\n[${splitter.directions.where((Direction _d) => _d == Direction.east).length}]', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                              ),
                              Material(
                                color: DynamicTheme.of(context).data.positiveActionButtonColor,
                                child: Container(
                                  child: InkWell(
                                    onTap: (){
                                      splitter.directions.add(Direction.east);
                                    },
                                    child: Container(
                                      width: 56.0,
                                      height: 56.0,
                                      child: Icon(Icons.add, color: DynamicTheme.of(context).data.positiveActionIconColor,),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Material(
                            color: DynamicTheme.of(context).data.negativeActionButtonColor,
                            child: Container(
                              child: InkWell(
                                onTap: (){
                                  splitter.directions.remove(Direction.north);
                                },
                                child: Container(
                                  width: 56.0,
                                  height: 56.0,
                                  child: Icon(Icons.remove, color: DynamicTheme.of(context).data.negativeActionIconColor,),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text('↓\n[${splitter.directions.where((Direction _d) => _d == Direction.north).length}]', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                          ),
                          Material(
                            color: DynamicTheme.of(context).data.positiveActionButtonColor,
                            child: Container(
                              child: InkWell(
                                onTap: (){
                                  splitter.directions.add(Direction.north);
                                },
                                child: Container(
                                  width: 56.0,
                                  height: 56.0,
                                  child: Icon(Icons.add, color: DynamicTheme.of(context).data.positiveActionIconColor,),
                                ),
                              ),
                            ),
                          ),
                        ],
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
