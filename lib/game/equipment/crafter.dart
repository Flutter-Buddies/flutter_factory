import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Crafter extends FactoryEquipment{
  Crafter(Coordinates coordinates, Direction direction, this.craftMaterial, {int craftingTickDuration = 1}) : _recipe = FactoryMaterial.getRecipeFromType(craftMaterial), super(coordinates, direction, EquipmentType.crafter, tickDuration: craftingTickDuration);

  final Map<FactoryRecipeMaterialType, int> _recipe;
  FactoryMaterialType craftMaterial;

  FactoryMaterial _crafted;

  bool isCrafting = false;
  bool _didToggle = false;

  int getRecipeAmount(FactoryMaterialType fmt){
    return _recipe[fmt] ?? 0;
  }

  bool get canCraft{
    if(isCrafting){
      return false;
    }

    bool canCraft = true;
    _recipe.keys.forEach((FactoryRecipeMaterialType fmt){
      canCraft = canCraft && _recipe[fmt] <= objects.where((FactoryMaterial fm) => fm.type == fmt.materialType && fm.state == fmt.state).length;
    });
    return canCraft;
  }

  bool _temp;

  @override
  List<FactoryMaterial> tick() {
    _temp = isCrafting && counter % tickDuration == tickDuration - 1;

    isCrafting = isCrafting && counter % tickDuration != 0;
    _didToggle = _temp == isCrafting;

    if(isCrafting){
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
    _recipe.addAll(FactoryMaterial.getRecipeFromType(craftMaterial));
  }

  void _craft(){
    if(canCraft){
      isCrafting = true;
      _recipe.keys.forEach((FactoryRecipeMaterialType fmt){
        for(int j = 0; j < _recipe[fmt]; j++){
          objects.remove(objects.firstWhere((FactoryMaterial fm) => fm.type == fmt.materialType && fm.state == fmt.state, orElse: () => null));
        }
      });

      _crafted = FactoryMaterial.getFromType(craftMaterial, offset: pointingOffset);
      _crafted.direction = direction;
    }else{
      _didToggle = false;
    }
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    double _myProgress = ((counter % tickDuration) / tickDuration) + (progress / tickDuration);
    double _machineProgress = (counter % tickDuration) >= (tickDuration / 2) ? _myProgress : (1 - _myProgress);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
//    canvas.drawRect(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Paint()..color = Colors.grey.shade900);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)), Radius.circular(size / 2.2 / 2)), Paint()..color = Colors.grey.shade900);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4)), Radius.circular(size / 2.4 / 2)), Paint()..color = Color.lerp(Colors.red, Colors.green, _didToggle ? (_temp == isCrafting ? 1 - progress : progress) : (isCrafting ? 1 : 0)));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Radius.circular(size / 2.5 / 2)), Paint()..color = Colors.grey.shade900);


    canvas.save();
    canvas.scale(0.6);
    FactoryMaterial.getFromType(craftMaterial).drawMaterial(Offset.zero, canvas, progress);
    canvas.restore();
//    canvas.drawCircle(Offset(size / 4, size / 4), 4.0, Paint()..color = isCrafting || canCraft ? Colors.green : Colors.red);
    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress){
    double _moveX = 0.0;
    double _moveY = 0.0;

    if((counter + 1) % tickDuration != 0 || _crafted == null){
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

  @override
  FactoryEquipment copyWith({Coordinates coordinates, Direction direction, int tickDuration, FactoryMaterial craftMaterial}) {
    return Crafter(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      craftMaterial ?? this.craftMaterial,
      craftingTickDuration: tickDuration ?? this.tickDuration
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'craft_material': craftMaterial.index
    });
    return _map;
  }
}