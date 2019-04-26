import 'package:flutter/material.dart';
import 'package:flutter_factory/game/equipment/crafter.dart';
import 'package:flutter_factory/game/model/factory_material.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class CrafterOptionsWidget extends StatelessWidget {
  CrafterOptionsWidget({@required this.crafter, this.progress = 0.0, Key key}) : super(key: key);

  final Crafter crafter;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Craft recipe:'),
              DropdownButton<FactoryMaterialType>(
                value: crafter.craftMaterial,
                onChanged: (FactoryMaterialType fmt){
                  crafter.changeRecipe(fmt);
                },
                items: FactoryMaterialType.values.where((FactoryMaterialType fmt) => !FactoryMaterial.isRaw(fmt)).map((FactoryMaterialType fmt){
                  return DropdownMenuItem<FactoryMaterialType>(
                    value: fmt,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
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
                value: crafter.tickDuration,
                onChanged: (int fmt){
                  crafter.tickDuration = fmt;
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
                                  progress,
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
                          child: Center(child: Text('${crafter.objects.where((FactoryMaterial _fm) => _fm.type == fmt).length}', style: TextStyle(color: Colors.white),))
                        ),
                      ],
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
}
