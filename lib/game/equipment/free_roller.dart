import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class FreeRoller extends FactoryEquipment{
  FreeRoller(Coordinates coordinates, Direction equipmentDirection, {int tickDuration}) : super(coordinates, equipmentDirection, EquipmentType.freeRoller, tickDuration: tickDuration);

//  final int rotation;

  @override
  List<FactoryMaterial> tick() {
    final List<FactoryMaterial> _fm = <FactoryMaterial>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterial fm){
//      fm.direction = Direction.values[(fm.direction.index + rotation) % Direction.values.length];
      fm.moveMaterial();
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress){
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    double _size = size * 0.8;

    drawSplitter(Direction.south, canvas, size, progress, entry: true);
    drawSplitter(Direction.north, canvas, size, progress, entry: true);
    drawSplitter(Direction.east, canvas, size, progress, entry: true);
    drawSplitter(Direction.west, canvas, size, progress, entry: true);

    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.4, _size * 0.4), Offset(-_size * 0.4, -_size * 0.4)), Paint()..color = Colors.grey.shade600);

    for(int i = 0; i < 8; i++){
      for(int j = 0; j < 8; j++){
        canvas.drawCircle(Offset(_size * 0.35 + (i * (-_size * 0.1)), _size * 0.35 + (j * (-_size * 0.1))), _size * 0.045, Paint()..color = Colors.black54);
      }
    }

    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress) {
    objects.forEach((FactoryMaterial fm){
      double _moveX = 0.0;
      double _moveY = 0.0;

      switch(fm.direction){
        case Direction.east:
          _moveX = progress * size;
          break;
        case Direction.west:
          _moveX = -progress * size;
          break;
        case Direction.north:
          _moveY = progress * size;
          break;
        case Direction.south:
          _moveY = -progress * size;
          break;
      }

      fm.drawMaterial(offset + Offset(fm.offsetX + _moveX, fm.offsetY + _moveY), canvas, progress);
    });
  }

  @override
  FactoryEquipment copyWith({Coordinates coordinates, Direction direction, List<Direction> directions}) {
    return FreeRoller(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
    );
  }
}