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
              final List<FactoryRecipeMaterialType> _filteredForDirection = sorter.directions.keys.where((FactoryRecipeMaterialType fmt) => sorter.directions[fmt] == d).toList();

              return Container(
                height: 120.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('${d == sorter.direction ? 'MAIN EXIT - ' : ''}${directionToString(d)} - (${sorter.directions.values.where((Direction _d) => _d == d).length})'),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _filteredForDirection.map((FactoryRecipeMaterialType fmt){
                        return ActionChip(
                          label: Row(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: CustomPaint(
                                  painter: ObjectPainter(
                                    progress,
                                    material: FactoryMaterial.getFromType(fmt.materialType)..state = fmt.state
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 12.0),
                                child: Text('${factoryMaterialToString(fmt.materialType)} ${factoryMaterialStateToString(fmt.state)}'),
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
                      onSelected: (FactoryRecipeMaterialType fmt){
                        sorter.directions.addAll(<FactoryRecipeMaterialType, Direction>{
                          fmt: d
                        });
                      },
                      itemBuilder: (BuildContext context){
                        List<PopupMenuItem<FactoryRecipeMaterialType>> _itemsList = <PopupMenuItem<FactoryRecipeMaterialType>>[];

                        FactoryMaterialType.values.where((FactoryMaterialType fmt) => FactoryMaterial.isRaw(fmt) && (!sorter.directions.containsKey(fmt) || sorter.directions[fmt] != d)).forEach((FactoryMaterialType fmt){
                          FactoryMaterialState.values.where((FactoryMaterialState fms) => fms.index < FactoryMaterialState.crafted.index).forEach((FactoryMaterialState fms){
                            _itemsList.add(PopupMenuItem<FactoryRecipeMaterialType>(
                              value: FactoryRecipeMaterialType(fmt, state: fms),
                              child: Text('${factoryMaterialToString(fmt)} ${fms == FactoryMaterialState.raw ? '' : factoryMaterialStateToString(fms)}'),
                            ));
                          });
                        });

                        _itemsList.addAll(FactoryMaterialType.values.where((FactoryMaterialType fmt) => !FactoryMaterial.isRaw(fmt) && (!sorter.directions.containsKey(fmt) || sorter.directions[fmt] != d)).map((FactoryMaterialType fmt){
                          return PopupMenuItem<FactoryRecipeMaterialType>(
                            value: FactoryRecipeMaterialType(fmt),
                            child: Text('${factoryMaterialToString(fmt)}'),
                          );
                        }));

                        return _itemsList;
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
