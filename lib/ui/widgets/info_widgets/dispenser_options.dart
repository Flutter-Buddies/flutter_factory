import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class DispenserOptionsWidget extends StatelessWidget {
  DispenserOptionsWidget({@required this.dispenser, this.progress = 0.0, Key key}) : super(key: key);

  final double progress;
  final List<Dispenser> dispenser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: dispenser.first.isMutable ? _showMutableWidget() : _showInMutableWidget(context),
    );
  }

  Widget _showInMutableWidget(BuildContext context){
    Dispenser _showFirst = dispenser.first;

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Produce material:'),
            Row(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: CustomPaint(
                    painter: ObjectPainter(
                      progress,
                      material: FactoryMaterialModel.getFromType(_showFirst.dispenseMaterial)
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 12.0),
                  child: Text('${factoryMaterialToString(_showFirst.dispenseMaterial)}'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 28.0),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Produce time:'),
            Text('${_showFirst.tickDuration.toString()}')
          ],
        ),
        SizedBox(height: 28.0),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Produce amount:'),
            Text('${_showFirst.dispenseAmount.toString()}')
          ],
        ),
        SizedBox(height: 36.0),

        Text('This ${equipmentTypeToString(_showFirst.type)} is part of the challenge and cannot be moved, modified or rotated!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.caption.copyWith(color: Colors.red, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 12.0),
      ],
    );
  }

  Widget _showMutableWidget(){
    Dispenser _showFirst = dispenser.first;

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Produce material:'),
            DropdownButton<FactoryMaterialType>(
              value: _showFirst.dispenseMaterial,
              onChanged: (FactoryMaterialType fmt){
                dispenser.forEach((Dispenser d) => d.dispenseMaterial = fmt);
              },
              items: FactoryMaterialType.values.where(FactoryMaterialModel.isRaw).map((FactoryMaterialType fmt){
                return DropdownMenuItem<FactoryMaterialType>(
                  value: fmt,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: CustomPaint(
                          painter: ObjectPainter(
                            progress,
                            material: FactoryMaterialModel.getFromType(fmt)
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 12.0),
                        child: Text('${factoryMaterialToString(fmt)}'),
                      ),
                    ],
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
            Text('Produce time:'),
            DropdownButton<int>(
              value: _showFirst.tickDuration,
              onChanged: (int fmt){
                dispenser.forEach((Dispenser d) => d.tickDuration = fmt);
              },
              items: List<int>.generate(12, (int i) => i + 1).map((int fmt){
                return DropdownMenuItem<int>(
                  value: fmt,
                  child: Text('${fmt.toString()}'),
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
            Text('Produce amount:'),
            DropdownButton<int>(
              value: _showFirst.dispenseAmount,
              onChanged: (int fmt){
                dispenser.forEach((Dispenser d) => d.dispenseAmount = fmt);
              },
              items: List<int>.generate(12, (int i) => i + 1).map((int fmt){
                return DropdownMenuItem<int>(
                  value: fmt,
                  child: Text('${fmt.toString()}'),
                );
              }).toList(),
            )
          ],
        ),
        SizedBox(height: 28.0),
      ],
    );
  }
}
