import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/material/copper.dart';
import 'package:flutter_factory/game/material/diamond.dart';
import 'package:flutter_factory/game/material/gold.dart';
import 'package:flutter_factory/game/material/iron.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Dispenser extends FactoryEquipment{
  Dispenser(Coordinates coordinates, Direction direction, this.dispenseMaterial, {this.dispenseAmount = 1, int dispenseTickDuration = 3}) : super(coordinates, direction, EquipmentType.dispenser, tickDuration: dispenseTickDuration);

  FactoryMaterialType dispenseMaterial;

  int counter = 0;
  int dispenseAmount;
  List<FactoryMaterial> _materials = <FactoryMaterial>[];


  @override
  List<FactoryMaterial> tick() {
    counter++;

    if(_materials.isNotEmpty){
      final List<FactoryMaterial> _fml = <FactoryMaterial>[]..addAll(_materials);
      _materials.clear();

      if(tickDuration == 1){
        _materials = List<FactoryMaterial>.generate(dispenseAmount, (int index) => _getMaterial());
      }

      return _fml;
    }else if((counter - 1) % tickDuration != 0){
      return <FactoryMaterial>[];
    }

    _materials = List<FactoryMaterial>.generate(dispenseAmount, (int index) => _getMaterial());

    return <FactoryMaterial>[];
  }

  FactoryMaterial _getMaterial(){
    switch(dispenseMaterial){
      case FactoryMaterialType.gold:
        return Gold.fromOffset(pointingOffset);
      case FactoryMaterialType.iron:
        return Iron.fromOffset(pointingOffset);
      case FactoryMaterialType.diamond:
        return Diamond.fromOffset(pointingOffset);
      case FactoryMaterialType.copper:
        return Copper.fromOffset(pointingOffset);
      default:
        return Iron.fromOffset(pointingOffset);
    }
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRect(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Paint()..color = Colors.red);
    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress){
    double _moveX = 0.0;
    double _moveY = 0.0;

    if(_materials.isEmpty){
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

    _materials.forEach((FactoryMaterial fm){
      fm.drawMaterial(offset + Offset(fm.offsetX + _moveX, fm.offsetY + _moveY), canvas, progress);
    });
  }
}