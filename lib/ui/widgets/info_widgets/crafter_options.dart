import 'package:flutter/material.dart';
import 'package:flutter_factory/game/equipment/crafter.dart';
import 'package:flutter_factory/game/model/factory_material.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class CrafterOptionsWidget extends StatelessWidget {
  CrafterOptionsWidget({@required this.crafter, this.progress = 0.0, Key key}) : super(key: key);

  final List<Crafter> crafter;
  final double progress;

  @override
  Widget build(BuildContext context) {
    Crafter _showFirst = crafter.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Craft recipe:'),
              DropdownButtonHideUnderline(
                child: DropdownButton<FactoryMaterialType>(
                  value: _showFirst.craftMaterial,
                  onChanged: (FactoryMaterialType fmt){
                    crafter.forEach((Crafter c) => c.changeRecipe(fmt));
                  },
                  items: FactoryMaterialType.values.where((FactoryMaterialType fmt) => !FactoryMaterial.isRaw(fmt)).map((FactoryMaterialType fmt){
                    Map<FactoryRecipeMaterialType, int> _recepie = FactoryMaterial.getRecipeFromType(fmt);

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

                            Row(
                              children: _recepie.keys.map((FactoryRecipeMaterialType fmrt){
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Row(
                                    children: <Widget>[
                                      CustomPaint(
                                        painter: ObjectPainter(
                                          progress,
                                          material: FactoryMaterial.getFromType(fmrt.materialType)..state = fmrt.state
                                        ),
                                      ),

                                      SizedBox(width: 12.0,),
                                      Text('${_recepie[fmrt]}', style: Theme.of(context).textTheme.caption,)
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        )
                      ),
                    );
                  }).toList(),
                ),
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
                value: _showFirst.tickDuration,
                onChanged: (int fmt){
                  crafter.forEach((Crafter c) => c.tickDuration = fmt);
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
                    label: Column(
                      children: <Widget>[
                        Row(
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
                              child: Center(child: Text('${_showFirst.objects.where((FactoryMaterial _fm) => _fm.type == fmt).length}', style: TextStyle(color: Colors.white),))
                            ),
                          ],
                        ),

                        FactoryMaterial.isRaw(fmt) ? Row(
                          children: FactoryMaterialState.values.where((FactoryMaterialState fms) => fms.index < 4).map((FactoryMaterialState states){
                            return Row(
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: CustomPaint(
                                    painter: ObjectPainter(
                                      progress,
                                      material: FactoryMaterial.getFromType(fmt)..state = states
                                    ),
                                  ),
                                ),
                                Text('${_showFirst.objects.where((FactoryMaterial _fm) => _fm.type == fmt && _fm.state == states).length}'),
                              ],
                            );
                          }).toList(),
                        ) : SizedBox.shrink()
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
