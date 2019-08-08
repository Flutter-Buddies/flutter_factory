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
      fm.direction = (directions.containsKey(fm.type) && fm.state == FactoryMaterialState.raw) ? directions[fm.type] : direction;
      fm.moveMaterial();
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
//    drawSplitter(Direction.values[(direction.index - 2) % Direction.values.length], canvas, size, progress, entry: true);
    drawSplitter(direction, canvas, size, progress);
    directions.values.forEach((Direction d) => drawSplitter(d, canvas, size, progress));

    canvas.restore();
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)), Radius.circular(size / 2.2 / 2)), Paint()..color = Colors.grey.shade700);

    Paint _gatesPaint = Paint();
    _gatesPaint.color = Colors.grey.shade600;

    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.south || objects.indexWhere((FactoryMaterial fm) => fm.state == FactoryMaterialState.raw && directions[fm.type] == Direction.south) != -1){
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


    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.north || objects.indexWhere((FactoryMaterial fm) => fm.state == FactoryMaterialState.raw && directions[fm.type] == Direction.north) != -1){
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


    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.east || objects.indexWhere((FactoryMaterial fm) => fm.state == FactoryMaterialState.raw && directions[fm.type] == Direction.east) != -1){
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


    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.west || objects.indexWhere((FactoryMaterial fm) => fm.state == FactoryMaterialState.raw && directions[fm.type] == Direction.west) != -1){
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

      switch(fm.state == FactoryMaterialState.raw && directions.containsKey(fm.type) ? directions[fm.type] : direction){
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

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'sorter_directions': directions.keys.map((FactoryMaterialType type) => <String, int>{
        'material_type': type.index,
        'direction': directions[type].index
      }).toList(),
    });

    print('Map: $_map');

    return _map;
  }
}