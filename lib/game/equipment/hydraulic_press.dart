import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class HydraulicPress extends FactoryEquipment{
  HydraulicPress(Coordinates coordinates, Direction direction, {this.pressCapacity = 1, int tickDuration = 1}) : super(coordinates, direction, EquipmentType.hydraulic_press, tickDuration: tickDuration);

  final int pressCapacity;

  List<FactoryMaterial> _outputMaterial = <FactoryMaterial>[];

  @override
  HydraulicPress copyWith({Coordinates coordinates, Direction direction, int pressCapacity}) {
    return HydraulicPress(
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
      _outputMaterial.forEach((FactoryMaterial m)=> m.changeState(FactoryMaterialState.plate));

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

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    double _myProgress = ((counter % tickDuration) / tickDuration) + (progress / tickDuration);
    double _machineProgress = (counter % tickDuration) >= (tickDuration / 2) ? _myProgress : (1 - _myProgress);

    if(tickDuration == 1){
      _machineProgress = _outputMaterial.isEmpty ? progress : (1 - progress);
    }

    if(objects.isEmpty && _outputMaterial.isEmpty){
      _machineProgress = 0.0;
    }

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    //    canvas.drawRect(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Paint()..color = Colors.grey.shade900);

    Path _machineLegs = Path();

    if(direction == Direction.east || direction == Direction.west){
      _machineLegs.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, size / 3.0)), bottomLeft: Radius.circular(size / 2.2 / 2), bottomRight: Radius.circular(size / 2.2 / 2)));
      _machineLegs.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(size / 2.2, -size / 2.2), Offset(-size / 2.2, -size / 3.0)), topLeft: Radius.circular(size / 2.2 / 2), topRight: Radius.circular(size / 2.2 / 2)));
    }else{
      _machineLegs.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(size / 3.0, -size / 2.2)), topRight: Radius.circular(size / 2.2 / 2), bottomRight: Radius.circular(size / 2.2 / 2)));
      _machineLegs.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(-size / 2.2, size / 2.2), Offset(-size / 3.0, -size / 2.2)), bottomLeft: Radius.circular(size / 2.2 / 2), topLeft: Radius.circular(size / 2.2 / 2)));
    }
//    _path.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2))));
    canvas.drawPath(_machineLegs, Paint()..color = Colors.grey.shade100);


    double _change = Curves.easeInCubic.transform(_machineProgress) * 3;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)).deflate(_change), Radius.circular(size / 2.5 / 2)).deflate(_change), Paint()..color = Colors.yellow);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.7, size / 2.7), Offset(-size / 2.7, -size / 2.7)).deflate(_change), Radius.circular(size / 2.7 / 2)).deflate(_change), Paint()..color = Colors.grey.shade700);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4)), Radius.circular(size / 2.4 / 2)), Paint()..color = Colors.white24);

    Path _machineTop = Path();
    if(direction == Direction.east || direction == Direction.west){
      _machineTop.addRect(Rect.fromPoints(Offset(size / 3.8, size / 2.2), Offset(size / 5.0, -size / 2.2)));
      _machineTop.addRect(Rect.fromPoints(Offset(-size / 3.8, size / 2.2), Offset(-size / 5.0, -size / 2.2)));
    }else{
      _machineTop.addRect(Rect.fromPoints(Offset(size / 2.2, size / 3.8), Offset(-size / 2.2, size / 5.0)));
      _machineTop.addRect(Rect.fromPoints(Offset(size / 2.2, -size / 3.8), Offset(-size / 2.2, -size / 5.0)));
    }
    canvas.drawPath(_machineTop, Paint()..color = Colors.white);
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
    Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'press_capacity': pressCapacity
    });
    return _map;
  }
}