import 'package:flutter/material.dart';
import 'package:flutter_factory/game/equipment/sorter.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class SorterOptionsWidget extends StatelessWidget {
  SorterOptionsWidget({@required this.sorter, this.progress = 0.0, Key key}) : super(key: key);

  final Sorter sorter;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: <Widget>[
          Text('Sort:'),
          Column(
            children: Direction.values.map((Direction d){
              if(d == Direction.values[(sorter.direction.index + 2) % Direction.values.length]){
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

              List<FactoryMaterialType> _filteredForDirection = sorter.directions.keys.where((FactoryMaterialType fmt) => sorter.directions[fmt] == d).toList();

              return Container(
                height: 120.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('${d.toString().replaceAll('Direction.', '').toUpperCase()} - (${sorter.directions.values.where((Direction _d) => _d == d).length})'),
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
                                    progress,
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
                            sorter.directions.remove(fmt);
                          },
                        );
                      }).toList(),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.add),
                      onSelected: (FactoryMaterialType fmt){
                        sorter.directions.addAll(<FactoryMaterialType, Direction>{
                          fmt: d
                        });
                      },
                      itemBuilder: (BuildContext context){
                        return FactoryMaterialType.values.where((FactoryMaterialType fmt) => !sorter.directions.containsKey(fmt) || sorter.directions[fmt] != d).map((FactoryMaterialType fmt){
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
}
