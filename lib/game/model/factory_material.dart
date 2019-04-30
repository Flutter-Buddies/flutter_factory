import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/craftables/computer_chip.dart';
import 'package:flutter_factory/game/craftables/processor.dart';
import 'package:flutter_factory/game/material/aluminium.dart';
import 'package:flutter_factory/game/material/copper.dart';
import 'package:flutter_factory/game/material/diamond.dart';
import 'package:flutter_factory/game/material/gold.dart';
import 'package:flutter_factory/game/material/iron.dart';

import 'factory_equipment.dart';

abstract class FactoryMaterial{
  FactoryMaterial(this.x, this.y, this.value, this.type, {this.size = 8.0}) : offsetX = Random().nextDouble() * 14 - 7, offsetY = Random().nextDouble() * 14 - 7;

  double x;
  double y;

  double size;
  Direction direction;

  final double value;
  final double offsetX;
  final double offsetY;

  FactoryMaterialType type;


  static FactoryMaterial getFromType(FactoryMaterialType type, {Offset offset = Offset.zero}){
    switch(type){
      case FactoryMaterialType.iron:
        return Iron.fromOffset(offset);
      case FactoryMaterialType.copper:
        return Copper.fromOffset(offset);
      case FactoryMaterialType.diamond:
        return Diamond.fromOffset(offset);
      case FactoryMaterialType.gold:
        return Gold.fromOffset(offset);
      case FactoryMaterialType.aluminium:
        return Aluminium.fromOffset(offset);
      case FactoryMaterialType.computerChip:
        return ComputerChip.fromOffset(offset);
      case FactoryMaterialType.processor:
        return Processor.fromOffset(offset);
      default:
        return null;
    }
  }

  bool get isRawMaterial => type == FactoryMaterialType.iron
    || type == FactoryMaterialType.copper
    || type == FactoryMaterialType.gold
    || type == FactoryMaterialType.diamond
    || type == FactoryMaterialType.aluminium;

  Color getColor(){
    switch(type){
      case FactoryMaterialType.iron:
        return Colors.grey.shade300;
      case FactoryMaterialType.copper:
        return Colors.orange;
      case FactoryMaterialType.diamond:
        return Colors.blue;
      case FactoryMaterialType.gold:
        return Colors.yellow;
      case FactoryMaterialType.aluminium:
        return Colors.grey.shade100;
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
      case FactoryMaterialType.processor:
        return <FactoryMaterialType, int>{
          FactoryMaterialType.computerChip: 2,
          FactoryMaterialType.aluminium: 2
        };
      /// Raw materials don't have recipe
      default:
        return <FactoryMaterialType, int>{};
    }
  }

  static bool isRaw(FactoryMaterialType type){
    switch(type){
      case FactoryMaterialType.computerChip:
      case FactoryMaterialType.processor:
        return false;
      /// Raw materials don't have recipe
      default:
        return true;
    }
  }

  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    canvas.drawRect(
      Rect.fromCircle(center: offset, radius: size + 0.2),
      Paint()..color = Colors.black.withOpacity(opacity)
    );

    canvas.drawRect(
      Rect.fromCircle(center: offset, radius: size),
      Paint()..color = getColor().withOpacity(opacity)
    );
  }
}

enum FactoryMaterialType{
  iron, copper, diamond, gold, aluminium, computerChip, processor
}

class FactoryRecipe{
  FactoryRecipe(this.recipe);

  final Map<FactoryMaterialType, int> recipe;
}