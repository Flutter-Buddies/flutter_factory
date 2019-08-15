import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class SelectedObjectInfoWidget extends StatelessWidget {
  SelectedObjectInfoWidget({this.progress = 0.0, @required this.equipment, Key key}) : super(key: key);

  final double progress;
  final FactoryEquipment equipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      margin: EdgeInsets.symmetric(vertical: 36.0, horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                child: Text('${equipment.type.toString().replaceAll('EquipmentType.', '').toUpperCase()}',
                  style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 18.0),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 36.0),
                transform: Matrix4.diagonal3Values(2.4, 2.4, 2.4),
                child: CustomPaint(
                  painter: ObjectPainter(
                    progress,
                    objectSize: 32.0,
                    equipment: equipment
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
