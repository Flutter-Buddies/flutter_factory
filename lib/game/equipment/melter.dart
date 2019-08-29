import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Melter extends FactoryEquipment{
  Melter(Coordinates coordinates, Direction direction, {this.meltCapacity = 1, int tickDuration = 1}) : super(coordinates, direction, EquipmentType.melter, tickDuration: tickDuration);

  final int meltCapacity;

  List<FactoryMaterial> _outputMaterial = <FactoryMaterial>[];

  @override
  Melter copyWith({Coordinates coordinates, Direction direction, int meltCapacity}) {
    return Melter(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      meltCapacity: meltCapacity ?? this.meltCapacity
    );
  }

  @override
  List<FactoryMaterial> tick() {
    if(tickDuration > 1 && counter % tickDuration != 1 && _outputMaterial.isEmpty){
      print('Not ticking!');
      return <FactoryMaterial>[];
    }

    if(tickDuration == 1){
      final List<FactoryMaterial> _fm = <FactoryMaterial>[]..addAll(_outputMaterial);
      _outputMaterial.clear();
      _processMaterial();

      _fm.map((FactoryMaterial fm){
        fm.direction = direction;
        fm.moveMaterial();
      }).toList();

      return _fm;
    }

    if(_outputMaterial.isEmpty){
      _processMaterial();
      return <FactoryMaterial>[];
    }

    final List<FactoryMaterial> _material = <FactoryMaterial>[]..addAll(_outputMaterial);
    _outputMaterial.clear();

    _material.map((FactoryMaterial fm){
      fm.direction = direction;
      fm.moveMaterial();
    }).toList();

    return _material;
  }

  void _processMaterial(){
    _outputMaterial = objects.getRange(0, min(meltCapacity, objects.length)).toList();
    objects.removeRange(0, min(meltCapacity, objects.length));
    _outputMaterial.forEach((FactoryMaterial m)=> m.changeState(FactoryMaterialState.fluid));
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    double _myProgress = ((counter % tickDuration) / tickDuration) + (progress / tickDuration);
    double _machineProgress = (counter % tickDuration) >= (tickDuration / 2) ? _myProgress : (1 - _myProgress);

    if(tickDuration == 1){
      _machineProgress = (_myProgress > 0.5) ? ((_myProgress * 2) - 1) : (1 - (_myProgress * 2));
    }

    if(objects.isEmpty && _outputMaterial.isEmpty){
      _machineProgress = 0.0;
    }

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4)), Radius.circular(size / 2.4 / 2)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.6, size / 2.6), Offset(-size / 2.6, -size / 2.6)), Radius.circular(size / 2.6 / 2)), Paint()..color = Color.lerp(Colors.white, Colors.red, _machineProgress));

    canvas.restore();
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    super.drawTrack(offset, canvas, size, progress);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    drawRoller(direction, canvas, size, progress);

    if(direction == Direction.east || direction == Direction.west){
      canvas.drawRect(Rect.fromPoints(Offset(size / 3, size / 3), Offset(-size / 3, -size / 3)), Paint()..color = Colors.grey.shade800);
      for(int i = 0; i < 3; i++){
        final double _xOffset = ((size / 6) * i + (direction == Direction.east ? progress : -progress) * size) % (size * 0.5);
        canvas.drawLine(Offset(_xOffset - size / 6, size / 3), Offset(_xOffset - size / 6, -size / 3), Paint()..color = Colors.white70);
      }
    }else{
      canvas.drawRect(Rect.fromPoints(Offset(size / 3, size / 3), Offset(-size / 3, -size / 3)), Paint()..color = Colors.grey.shade800);

      for(int i = 0; i < 3; i++){
        double _yOffset = ((size / 6) * i + (direction == Direction.north ? progress : -progress) * size) % (size * 0.5);

        canvas.drawLine(Offset(size / 3, _yOffset - size / 3), Offset(-size / 3, _yOffset - size / 3), Paint()..color = Colors.white70);
      }
    }

    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress){
    double _moveX = 0.0;
    double _moveY = 0.0;

    if(_outputMaterial.isEmpty){
      return;
    }

    switch(direction){
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

    _outputMaterial.forEach((FactoryMaterial fm) => fm.drawMaterial(offset + Offset(_moveX + fm.offsetX, _moveY + fm.offsetY), canvas, progress));
  }


  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'melt_capacity': meltCapacity
    });
    return _map;
  }
}