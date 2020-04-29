import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class SelectedObjectInfoWidget extends StatelessWidget {
  const SelectedObjectInfoWidget({this.progress = 0.0, @required this.equipment, Key key}) : super(key: key);

  final double progress;
  final FactoryEquipmentModel equipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            child: Text(
              '${equipmentTypeToString(equipment.type)}',
              style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 18.0),
            ),
          ),
          Container(
            height: 92.0,
            width: 92.0,
            child: CustomPaint(
              painter: ObjectPainter(
                progress,
                theme: DynamicTheme.of(context).data,
                objectSize: 92.0,
                equipment: equipment,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
