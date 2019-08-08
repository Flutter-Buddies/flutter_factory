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
      fm.direction = direction;
      fm.moveMaterial();
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    super.drawTrack(offset, canvas, size, progress);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if(direction == Direction.east || direction == Direction.west){
      canvas.drawRect(Rect.fromPoints(Offset(size / 3, size / 3), Offset(-size / 3, -size / 3)), Paint()..color = Colors.grey.shade800);
    }else{
      canvas.drawRect(Rect.fromPoints(Offset(size / 3, size / 3), Offset(-size / 3, -size / 3)), Paint()..color = Colors.grey.shade800);
    }

    void drawLines(Direction d, {bool entry = false}){
      switch(d){
        case Direction.west:
          for(int i = 0; i < 4; i++){
            double _xOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(_xOffset - size / 3 - size / 3 + size / 2, size / 3), Offset(_xOffset - size / 3 - size / 3 + size / 2, -size / 3), Paint()..color = Colors.white70);
          }
          break;
        case Direction.east:
          for(int i = 0; i < 4; i++){
            double _xOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(_xOffset - size / 3 - size / 3 + size / 2, size / 3), Offset(_xOffset - size / 3 - size / 3 + size / 2, -size / 3), Paint()..color = Colors.white70);
          }
          break;
        case Direction.south:
          for(int i = 0; i < 4; i++){
            double _yOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3 + size / 2), Offset(-size / 3, _yOffset - size / 3 - size / 3 + size / 2), Paint()..color = Colors.white70);
          }
          break;
        case Direction.north:
          for(int i = 0; i < 4; i++){
            double _yOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3 + size / 2), Offset(-size / 3, _yOffset - size / 3 - size / 3 + size / 2), Paint()..color = Colors.white70);
          }
          break;
      }
    }

    drawLines(direction);

    canvas.restore();
  }

  @override
  FactoryEquipment copyWith({Coordinates coordinates, Direction direction, int tickDuration}) {
    return Roller(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      rollerTickDuration: tickDuration ?? this.tickDuration
    );
  }
}