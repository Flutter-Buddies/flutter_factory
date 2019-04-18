import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/craftables/computer_chip.dart';
import 'package:flutter_factory/game/material/copper.dart';
import 'package:flutter_factory/game/material/diamond.dart';
import 'package:flutter_factory/game/material/gold.dart';
import 'package:flutter_factory/game/material/iron.dart';

abstract class FactoryMaterial{
  FactoryMaterial(this.x, this.y, this.type, {this.size = 8.0}) : offsetX = Random().nextDouble() * 14 - 7, offsetY = Random().nextDouble() * 14 - 7;

  double x;
  double y;

  double size;

  final double offsetX;
  final double offsetY;

  FactoryMaterialType type;


  static FactoryMaterial getFromType(FactoryMaterialType type){
    switch(type){
      case FactoryMaterialType.iron:
        return Iron.fromOffset(Offset.zero);
      case FactoryMaterialType.copper:
        return Copper.fromOffset(Offset.zero);
      case FactoryMaterialType.diamond:
        return Diamond.fromOffset(Offset.zero);
      case FactoryMaterialType.gold:
        return Gold.fromOffset(Offset.zero);
      case FactoryMaterialType.computerChip:
        return ComputerChip.fromOffset(Offset.zero);
      default:
        return null;
    }
  }

  bool get isRawMaterial => type == FactoryMaterialType.iron
    || type == FactoryMaterialType.copper
    || type == FactoryMaterialType.gold
    || type == FactoryMaterialType.diamond;

  Color getColor(){
    switch(type){
      case FactoryMaterialType.iron:
        return Colors.grey.shade200;
      case FactoryMaterialType.copper:
        return Colors.orange;
      case FactoryMaterialType.diamond:
        return Colors.blue;
      case FactoryMaterialType.gold:
        return Colors.yellow;
      default:
        return Colors.red;
    }
  }

  static Map<FactoryMaterialType, int> getRecipe(FactoryMaterialType type){
    switch(type){
      case FactoryMaterialType.computerChip:
        return <FactoryMaterialType, int>{
          FactoryMaterialType.iron: 2,
          FactoryMaterialType.gold: 1
        };
      /// Raw materials don't have recipe
      default:
        return <FactoryMaterialType, int>{};
    }
  }

  static bool isRaw(FactoryMaterialType type){
    switch(type){
      case FactoryMaterialType.computerChip:
        return false;
      /// Raw materials don't have recipe
      default:
        return true;
    }
  }

  void drawMaterial(Offset offset, Canvas canvas, double progress){
    canvas.drawRect(
      Rect.fromCircle(center: offset, radius: size + 0.2),
      Paint()..color = Colors.black
    );

    canvas.drawRect(
      Rect.fromCircle(center: offset, radius: size),
      Paint()..color = getColor()
    );
  }
}

enum FactoryMaterialType{
  iron, copper, diamond, gold, computerChip
}

class FactoryRecipe{
  FactoryRecipe(this.recipe);

  final Map<FactoryMaterialType, int> recipe;
}