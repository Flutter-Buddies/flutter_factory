import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Roller extends FactoryEquipment{
  Roller(Coordinates coordinates, Direction direction, {int rollerTickDuration = 1}) : super(coordinates, direction, EquipmentType.roller, tickDuration: rollerTickDuration);

  @override
  List<FactoryMaterial> tick() {
    final List<FactoryMaterial> _fm = <FactoryMaterial>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterial fm){
      switch(direction){
        case Direction.west:
          fm.x -= 1.0;
          break;
        case Direction.east:
          fm.x += 1.0;
          break;
        case Direction.south:
          fm.y -= 1.0;
          break;
        case Direction.north:
          fm.y += 1.0;
          break;
      }
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    //    canvas.drawCircle(Offset.zero, 10.0, Paint()..color = Colors.red);
    if(direction == Direction.east || direction == Direction.west){
      canvas.drawRect(Rect.fromPoints(Offset(size / 2, size / 3), Offset(-size / 2, -size / 3)), Paint()..color = Colors.grey.shade800);
      for(int i = 0; i < 6; i++){
        double _xOffset = ((size / 6) * i + (direction == Direction.east ? progress : -progress) * size) % size;

        canvas.drawLine(Offset(_xOffset - size / 2, size / 3), Offset(_xOffset - size / 2, -size / 3), Paint()..color = Colors.white70);
      }
    }else{
      canvas.drawRect(Rect.fromPoints(Offset(size / 3, size / 2), Offset(-size / 3, -size / 2)), Paint()..color = Colors.grey.shade800);

      for(int i = 0; i < 6; i++){
        double _yOffset = ((size / 6) * i + (direction == Direction.north ? progress : -progress) * size) % size;

        canvas.drawLine(Offset(size / 3, _yOffset - size / 2), Offset(-size / 3, _yOffset - size / 2), Paint()..color = Colors.white70);
      }
    }

    canvas.restore();
  }
}