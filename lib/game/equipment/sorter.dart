import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Sorter extends FactoryEquipment{
  Sorter(Coordinates coordinates, Direction equipmentDirection, this.directions) : super(coordinates, equipmentDirection, EquipmentType.sorter);

  final Map<FactoryMaterialType, Direction> directions;

  @override
  List<FactoryMaterial> tick() {
    final List<FactoryMaterial> _fm = <FactoryMaterial>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterial fm){
      switch(directions.containsKey(fm.type) ? directions[fm.type] : direction){
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
    _drawSplitter(Direction.values[(direction.index - 2) % Direction.values.length], entry: true);
    _drawSplitter(direction);
    directions.values.forEach(_drawSplitter);

    canvas.restore();
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)), Radius.circular(size / 2.2 / 2)), Paint()..color = Colors.grey.shade700);

    Paint _gatesPaint = Paint();
    _gatesPaint.color = Colors.grey.shade600;

    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.south || objects.indexWhere((FactoryMaterial fm) => directions[fm.type] == Direction.south) != -1){
      _gatesPaint.color = Colors.green;
    }else{
      _gatesPaint.color = Colors.grey.shade600;
    }

    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(size * 0.02, size / 2.2),
        Offset(-size * 0.02, size * 0.25),
      ),
      topRight: Radius.circular(6.0),
      topLeft: Radius.circular(6.0)
    ), _gatesPaint);


    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.north || objects.indexWhere((FactoryMaterial fm) => directions[fm.type] == Direction.north) != -1){
      _gatesPaint.color = Colors.green;
    }else{
      _gatesPaint.color = Colors.grey.shade600;
    }

    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(-size * 0.02, -size / 2.2),
        Offset(size * 0.02, -size * 0.25),
      ),
      bottomLeft: Radius.circular(6.0),
      bottomRight: Radius.circular(6.0)
    ), _gatesPaint);


    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.east || objects.indexWhere((FactoryMaterial fm) => directions[fm.type] == Direction.east) != -1){
      _gatesPaint.color = Colors.green;
    }else{
      _gatesPaint.color = Colors.grey.shade600;
    }

    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(size / 2.2, size * 0.02),
        Offset(size * 0.25, -size * 0.02),
      ),
      topLeft: Radius.circular(6.0),
      bottomLeft: Radius.circular(6.0),
    ), _gatesPaint);


    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.west || objects.indexWhere((FactoryMaterial fm) => directions[fm.type] == Direction.west) != -1){
      _gatesPaint.color = Colors.green;
    }else{
      _gatesPaint.color = Colors.grey.shade600;
    }

    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(-size / 2.2, -size * 0.02),
        Offset(-size * 0.25, size * 0.02),
      ),
      topRight: Radius.circular(6.0),
      bottomRight: Radius.circular(6.0),
    ), _gatesPaint);

    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress) {
    objects.reversed.forEach((FactoryMaterial fm){
      double _moveX = 0.0;
      double _moveY = 0.0;

      switch(directions.containsKey(fm.type) ? directions[fm.type] : direction){
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
    return Sorter(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      directions ?? this.directions,
    );
  }
}