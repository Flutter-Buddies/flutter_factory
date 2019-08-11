import 'package:flutter/material.dart';
import 'package:flutter_factory/game/equipment/dispenser.dart';
import 'package:flutter_factory/game/model/factory_material.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class DispenserOptionsWidget extends StatelessWidget {
  DispenserOptionsWidget({@required this.dispenser, this.progress = 0.0, Key key}) : super(key: key);

  final double progress;
  final List<Dispenser> dispenser;

  @override
  Widget build(BuildContext context) {
    Dispenser _showFirst = dispenser.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
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
                items: FactoryMaterialType.values.where(FactoryMaterial.isRaw).map((FactoryMaterialType fmt){
                  return DropdownMenuItem<FactoryMaterialType>(
                    value: fmt,
                    child: Row(
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
                items: List<int>.generate(8, (int i) => i + 1).map((int fmt){
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
                items: List<int>.generate(8, (int i) => i + 1).map((int fmt){
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
      ),
    );
  }
}
