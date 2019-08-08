import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Splitter extends FactoryEquipment{
  Splitter(Coordinates coordinates, Direction equipmentDirection, this.directions) : super(coordinates, equipmentDirection, EquipmentType.splitter);

  final List<Direction> directions;

  int splitCounter = 0;

  @override
  List<FactoryMaterial> tick() {
    final List<FactoryMaterial> _fm = <FactoryMaterial>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterial fm){
      fm.direction = directions[splitCounter % directions.length];
      fm.moveMaterial();
      splitCounter++;
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    drawSplitter(Direction.values[(direction.index + 2) % Direction.values.length], canvas, size, progress, entry: true);
    directions.forEach((Direction d) => drawSplitter(d, canvas, size, progress));

    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress) {
    objects.reversed.forEach((FactoryMaterial fm){
      double _moveX = 0.0;
      double _moveY = 0.0;

      switch(directions[(objects.indexOf(fm) + splitCounter) % directions.length]){
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

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'splitter_directions': directions.map((Direction d) => d.index).toList()
    });
    return _map;
  }
}