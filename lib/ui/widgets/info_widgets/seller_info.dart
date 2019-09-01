import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class SellerInfo extends StatelessWidget {
  SellerInfo({Key key, @required this.equipment}) : super(key: key);

  final Seller equipment;

  @override
  Widget build(BuildContext context) {
    Map<FactoryRecipeMaterialType, int> _items = <FactoryRecipeMaterialType, int>{};

    equipment.soldItems.getRange(max(equipment.soldItems.length - 60, 0), equipment.soldItems.length).forEach((List<FactoryRecipeMaterialType> list){
      list.forEach((FactoryRecipeMaterialType frmt){
        if(_items.containsKey(frmt)){
          _items[frmt] = ++_items[frmt];
        }else{
          _items.addAll(<FactoryRecipeMaterialType, int>{
            frmt: 1
          });
        }
      });
    });

    int _soldInTime = min(equipment.soldItems.length, 60);

    return Container(
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('\$${equipment.soldValue.toStringAsFixed(2)} per tick'),
              Text('\$${equipment.soldAverage.toStringAsFixed(2)} on average'),
            ],
          ),

          SizedBox(height: 24.0,),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            alignment: Alignment.centerLeft,
            child: Text('Sold in last $_soldInTime ticks:')
          ),
          SizedBox(height: 12.0,),
          Divider(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(flex: 2, child: Text('Material', textAlign: TextAlign.center,)),
                    Expanded(flex: 1, child: Text('Sold', textAlign: TextAlign.center,)),
                    Expanded(flex: 1, child: Text('Per tick', textAlign: TextAlign.center,)),
                  ],
                ),
                Divider(),
                Column(
                  children: _items.keys.map((FactoryRecipeMaterialType frmt){
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(flex: 2, child: Row(
                          children: <Widget>[
                            Container(
                              transform: Matrix4.translationValues(18.0, 18.0, 0.0),
                              child: CustomPaint(
                                size: Size(36.0, 36.0),
                                painter: ObjectPainter(
                                  0.0,
                                  scale: 2.0,
                                  material: FactoryMaterialModel.getFromType(frmt.materialType)..state = frmt.state,
                                ),
                              ),
                            ),
                            SizedBox(width: 24.0,),
                            Text(factoryMaterialToString(frmt.materialType)),
                          ],
                        )),
                        Expanded(flex: 1, child: Container(height: 40.0, color: Colors.grey.shade200, child: Center(child: Text(_items[frmt].toString(),)))),
                        Expanded(flex: 1, child: Text('${(_items[frmt] / _soldInTime).toStringAsFixed(2)}', textAlign: TextAlign.end,)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
