import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class SellerInfo extends StatelessWidget {
  const SellerInfo({Key key, @required this.equipment}) : super(key: key);

  final Seller equipment;

  @override
  Widget build(BuildContext context) {
    final Map<FactoryRecipeMaterialType, int> _items = <FactoryRecipeMaterialType, int>{};

    equipment.soldItems
        .getRange(max(equipment.soldItems.length - 60, 0), equipment.soldItems.length)
        .forEach((List<FactoryRecipeMaterialType> list) {
      void _sortSoldItems(FactoryRecipeMaterialType frmt) {
        if (_items.containsKey(frmt)) {
          _items[frmt] = ++_items[frmt];
        } else {
          _items.addAll(<FactoryRecipeMaterialType, int>{frmt: 1});
        }
      }

      list.forEach(_sortSoldItems);
    });

    final int _soldInTime = min(equipment.soldItems.length, 60);
    final List<FactoryRecipeMaterialType> _sortedKeys = _items.keys.toList()
      ..sort((FactoryRecipeMaterialType first, FactoryRecipeMaterialType second) =>
          first.materialType.index.compareTo(second.materialType.index));

    return Container(
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('\$${equipment.soldValue.toStringAsFixed(2)} per tick'),
              Text('\$${equipment.soldAverage.toStringAsFixed(2)} on average'),
            ],
          ),
          const SizedBox(
            height: 24.0,
          ),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              alignment: Alignment.centerLeft,
              child: Text('Sold in last $_soldInTime ticks:')),
          const SizedBox(
            height: 12.0,
          ),
          const Divider(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    Expanded(
                        flex: 2,
                        child: Text(
                          'Material',
                          textAlign: TextAlign.center,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Sold',
                          textAlign: TextAlign.center,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          'Per tick',
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
                const Divider(),
                Column(
                  children: _sortedKeys.map((FactoryRecipeMaterialType frmt) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            flex: 2,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: CustomPaint(
                                    painter: ObjectPainter(
                                      0.0,
                                      objectSize: 26.0,
                                      theme: DynamicTheme.of(context).data,
                                      material: FactoryMaterialModel.getFromType(frmt.materialType)..state = frmt.state,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 24.0,
                                ),
                                Text(factoryMaterialToString(frmt.materialType)),
                              ],
                            )),
                        Expanded(
                            flex: 1,
                            child: Container(
                                height: 40.0,
                                color: Colors.grey.shade200,
                                child: Center(
                                    child: Text(
                                  _items[frmt].toString(),
                                )))),
                        Expanded(
                            flex: 1,
                            child: Text(
                              '${(_items[frmt] / _soldInTime).toStringAsFixed(2)}',
                              textAlign: TextAlign.end,
                            )),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          equipment.isMutable
              ? const SizedBox.shrink()
              : Column(
                  children: <Widget>[
                    const SizedBox(height: 36.0),
                    Text(
                      'This ${equipmentTypeToString(equipment.type)} is part of the challenge and cannot be moved, modified or rotated!',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.caption.copyWith(color: Colors.red, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                ),
        ],
      ),
    );
  }
}
