import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/craftables/computer_chip.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Crafter extends FactoryEquipment{
  Crafter(Coordinates coordinates, Direction direction, this.craftMaterial, {int craftingTickDuration = 3}) : _recipe = FactoryMaterial.getRecipe(craftMaterial), super(coordinates, direction, EquipmentType.crafter, tickDuration: craftingTickDuration);

  final Map<FactoryMaterialType, int> _recipe;
  FactoryMaterialType craftMaterial;

  int counter = 0;
  FactoryMaterial _crafted;

  bool isCrafting = false;

  bool get canCraft{
    bool canCraft = true;
    _recipe.keys.forEach((FactoryMaterialType fmt){
      canCraft = canCraft && _recipe[fmt] <= objects.where((FactoryMaterial fm) => fm.type == fmt).length;
    });
    return canCraft;
  }

  @override
  List<FactoryMaterial> tick() {
    isCrafting = counter % tickDuration != 0;

    if(isCrafting){
      counter++;
      return <FactoryMaterial>[];
    }

    if(_crafted != null){
      final FactoryMaterial _fm = _crafted;
      _crafted = null;
      _craft();
      return <FactoryMaterial>[_fm];
    }

    _craft();

    return <FactoryMaterial>[];
  }

  void changeRecipe(FactoryMaterialType fmt){
    craftMaterial = fmt;
    _recipe.clear();
    _recipe.addAll(FactoryMaterial.getRecipe(craftMaterial));
  }

  void _craft(){
    if(canCraft){
      _recipe.keys.forEach((FactoryMaterialType fmt){
        for(int j = 0; j < _recipe[fmt]; j++){
          objects.remove(objects.firstWhere((FactoryMaterial fm) => fm.type == fmt, orElse: () => null));
        }
      });

      _crafted = ComputerChip.fromOffset(pointingOffset);
    }
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRect(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Paint()..color = Colors.grey.shade900);
    canvas.drawCircle(Offset(size / 4, size / 4), 4.0, Paint()..color = isCrafting || canCraft ? Colors.green : Colors.red);
    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress){
    double _moveX = 0.0;
    double _moveY = 0.0;

    if(isCrafting || _crafted == null){
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

    _crafted.drawMaterial(offset + Offset(_moveX + _crafted.offsetX, _moveY + _crafted.offsetY), canvas, progress);
  }
}