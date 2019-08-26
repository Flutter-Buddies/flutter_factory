import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Sorter extends FactoryEquipment{
  Sorter(Coordinates coordinates, Direction equipmentDirection, this.directions) : super(coordinates, equipmentDirection, EquipmentType.sorter);

  final Map<FactoryRecipeMaterialType, Direction> directions;

  @override
  List<FactoryMaterial> tick() {
    final List<FactoryMaterial> _fm = <FactoryMaterial>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterial fm){
      final FactoryRecipeMaterialType _frmt = directions.keys.firstWhere((FactoryRecipeMaterialType frmt) => frmt.materialType == fm.type && frmt.state == fm.state, orElse: () => null);
      fm.direction = directions.containsKey(_frmt) ? directions[_frmt] : direction;
      fm.moveMaterial();
    }).toList();

    return _fm;
  }

  bool _materialToDirection(FactoryMaterial fm, Direction direction){
    final FactoryRecipeMaterialType _frmt = directions.keys.firstWhere((FactoryRecipeMaterialType frmt) => frmt.materialType == fm.type && frmt.state == fm.state, orElse: () => null);
    if(_frmt == null){
      return false;
    }

    return fm.state == _frmt.state && directions[_frmt] == direction;
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    drawRoller(Direction.values[(direction.index - 2) % Direction.values.length], canvas, size, progress);
    drawRoller(direction, canvas, size, progress);
    directions.values.forEach((Direction d) => drawRoller(d, canvas, size, progress));

    canvas.restore();
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)), Radius.circular(size / 2.2 / 2)), Paint()..color = Colors.grey.shade700);

    Paint _gatesPaint = Paint();
    _gatesPaint.color = Colors.grey.shade600;

    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.south || objects.indexWhere((FactoryMaterial fm) => _materialToDirection(fm, Direction.south)) != -1){
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


    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.north || objects.indexWhere((FactoryMaterial fm) => _materialToDirection(fm, Direction.north)) != -1){
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


    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.east || objects.indexWhere((FactoryMaterial fm) => _materialToDirection(fm, Direction.east)) != -1){
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


    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.west || objects.indexWhere((FactoryMaterial fm) => _materialToDirection(fm, Direction.west)) != -1){
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
    objects.forEach((FactoryMaterial fm){
      double _moveX = 0.0;
      double _moveY = 0.0;

      final FactoryRecipeMaterialType _frmt = directions.keys.firstWhere((FactoryRecipeMaterialType frmt) => frmt.materialType == fm.type && frmt.state == fm.state, orElse: () => null);
      switch(directions.containsKey(_frmt) ? directions[_frmt] : direction){
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
      directions ?? this.directions
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'sorter_directions': directions.keys.map((FactoryRecipeMaterialType type) => <String, int>{
        'material_type': type.materialType.index,
        'material_state': type.state.index,
        'direction': directions[type].index
      }).toList(),
    });

    print('Map: $_map');

    return _map;
  }
}