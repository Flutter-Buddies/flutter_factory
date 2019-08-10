import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class WireBender extends FactoryEquipment{
  WireBender(Coordinates coordinates, Direction direction, {this.wireCapacity = 1, int tickDuration = 1}) : super(coordinates, direction, EquipmentType.wire_bender, tickDuration: tickDuration);

  final int wireCapacity;

  List<FactoryMaterial> _outputMaterial = <FactoryMaterial>[];

  @override
  WireBender copyWith({Coordinates coordinates, Direction direction, int wireCapacity}) {
    return WireBender(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      wireCapacity: wireCapacity ?? this.wireCapacity
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
    _outputMaterial = objects.getRange(0, min(wireCapacity, objects.length)).toList();
    objects.removeRange(0, min(wireCapacity, objects.length));
    _outputMaterial.forEach((FactoryMaterial m)=> m.changeState(FactoryMaterialState.spring));
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    double _machineProgress = ((counter % tickDuration) / tickDuration) + (progress / tickDuration);

    if(objects.isEmpty && _outputMaterial.isEmpty){
      _machineProgress = 0.0;
    }

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4)), Radius.circular(size / 2.4 / 2)), Paint()..color = Colors.white);

    final double _change = Curves.elasticInOut.transform(_machineProgress) * 6.28;
    final double _size = size / 4.2;
    final Paint _linesPaint = Paint();

    _linesPaint.strokeWidth = 0.6;
    _linesPaint.strokeJoin = StrokeJoin.round;
    _linesPaint.color = Colors.black54;
    canvas.drawLine(Offset(0.0, 0.0), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);
    _linesPaint.color = Colors.black12;
    canvas.drawLine(Offset(-size / 4, size / 4), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);
    canvas.drawLine(Offset(size / 4, size / 4), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);
    canvas.drawLine(Offset(size / 4, -size / 4), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);
    canvas.drawLine(Offset(-size / 4, -size / 4), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);

//    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)).deflate(_change), Radius.circular(size / 2.5 / 2)).deflate(_change), Paint()..color = Colors.yellow);
//    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.7, size / 2.7), Offset(-size / 2.7, -size / 2.7)).deflate(_change), Radius.circular(size / 2.7 / 2)).deflate(_change), Paint()..color = Colors.grey.shade700);

    canvas.restore();
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    super.drawTrack(offset, canvas, size, progress);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

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
      'wire_capacity': wireCapacity
    });
    return _map;
  }
}