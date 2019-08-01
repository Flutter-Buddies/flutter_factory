import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class WireBender extends FactoryEquipment{
  WireBender(Coordinates coordinates, Direction direction, {this.pressCapacity = 3, int tickDuration = 1}) : super(coordinates, direction, EquipmentType.wire_bender, tickDuration: tickDuration);

  final int pressCapacity;

  List<FactoryMaterial> _outputMaterial = <FactoryMaterial>[];

  @override
  WireBender copyWith({Coordinates coordinates, Direction direction, int pressCapacity}) {
    return WireBender(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      pressCapacity: pressCapacity ?? this.pressCapacity
    );
  }

  @override
  List<FactoryMaterial> tick() {
    if(tickDuration > 1 && counter % tickDuration != 1 && _outputMaterial.isEmpty){
      print('Not ticking!');
      return <FactoryMaterial>[];
    }

    if(_outputMaterial.isEmpty){
      _outputMaterial = objects.getRange(0, min(pressCapacity, objects.length)).toList();
      objects.removeRange(0, min(pressCapacity, objects.length));
      _outputMaterial.forEach((FactoryMaterial m)=> m.changeState(FactoryMaterialState.spring));

      return <FactoryMaterial>[];
    }

    final List<FactoryMaterial> _material = <FactoryMaterial>[]..addAll(_outputMaterial);
    _outputMaterial.clear();

    _material.map((FactoryMaterial fm){
      fm.direction = direction;

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

    return _material;
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
}