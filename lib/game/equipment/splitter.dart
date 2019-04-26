import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Splitter extends FactoryEquipment{
  Splitter(Coordinates coordinates, Direction equipmentDirection, this.directions) : super(coordinates, equipmentDirection, EquipmentType.splitter);

  final List<Direction> directions;

  int counter = 0;

  @override
  List<FactoryMaterial> tick() {
    final List<FactoryMaterial> _fm = <FactoryMaterial>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterial fm){
      switch(directions[counter % directions.length]){
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

      counter++;
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    void _drawSplitter(Direction d, {bool entry = false}){
      switch(d){
        case Direction.west:
          canvas.drawRect(Rect.fromCircle(center: Offset(-size / 3, 0.0), radius: size / 3), Paint()..color = Colors.grey.shade800);
          for(int i = 0; i < 3; i++){
            double _xOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 2);
            canvas.drawLine(Offset(_xOffset - size / 3 - size / 3, size / 3), Offset(_xOffset - size / 3 - size / 3, -size / 3), Paint()..color = Colors.white70);
          }
          break;
        case Direction.east:
          canvas.drawRect(Rect.fromCircle(center: Offset(size / 3, 0.0), radius: size / 3), Paint()..color = Colors.grey.shade800);
          for(int i = 0; i < 3; i++){
            double _xOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 2);
            canvas.drawLine(Offset(_xOffset - size / 3 + size / 3, size / 3), Offset(_xOffset - size / 3 + size / 3, -size / 3), Paint()..color = Colors.white70);
          }
          break;
        case Direction.south:
          canvas.drawRect(Rect.fromCircle(center: Offset(0.0, -size / 3), radius: size / 3), Paint()..color = Colors.grey.shade800);
          for(int i = 0; i < 3; i++){
            double _yOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 2);
            canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3), Offset(-size / 3, _yOffset - size / 3 - size / 3), Paint()..color = Colors.white70);
          }
          break;
        case Direction.north:
          canvas.drawRect(Rect.fromCircle(center: Offset(0.0, size / 3), radius: size / 3), Paint()..color = Colors.grey.shade800);
          for(int i = 0; i < 3; i++){
            double _yOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 2);
            canvas.drawLine(Offset(size / 3, _yOffset + size / 3 - size / 3), Offset(-size / 3, _yOffset + size / 3 - size / 3), Paint()..color = Colors.white70);
          }
          break;
      }
    }


    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    _drawSplitter(Direction.values[(direction.index + 2) % Direction.values.length], entry: true);
    directions.forEach(_drawSplitter);

    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress) {
    objects.reversed.forEach((FactoryMaterial fm){
      double _moveX = 0.0;
      double _moveY = 0.0;

      switch(directions[(objects.indexOf(fm) + counter) % directions.length]){
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
    return Splitter(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      directions ?? this.directions,
    );
  }
}