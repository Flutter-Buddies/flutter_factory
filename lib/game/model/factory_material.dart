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
  FactoryMaterial(this.x, this.y, this.value, this.type, {this.size = 8.0, this.state = FactoryMaterialState.raw}) : offsetX = Random().nextDouble() * 14 - 7, offsetY = Random().nextDouble() * 14 - 7;

  double x;
  double y;

  double size;
  Direction direction;

  final double value;
  final double offsetX;
  final double offsetY;
  final FactoryMaterialType type;

  FactoryMaterialState state;

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

  void changeState(FactoryMaterialState newState){
    if(state == FactoryMaterialState.crafted){
      return;
    }

    state = newState;
  }

  static Map<FactoryRecipeMaterialType, int> getRecipe(FactoryMaterialType type){
    switch(type){
      case FactoryMaterialType.computerChip:
        return <FactoryRecipeMaterialType, int>{
          FactoryRecipeMaterialType(FactoryMaterialType.copper): 2,
          FactoryRecipeMaterialType(FactoryMaterialType.gold): 1
        };
      case FactoryMaterialType.processor:
        return <FactoryRecipeMaterialType, int>{
          FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 2,
          FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 2
        };
      /// Raw materials don't have recipe
      default:
        return <FactoryRecipeMaterialType, int>{};
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
    if(isRawMaterial && state != FactoryMaterialState.raw){
      switch(state){
        case FactoryMaterialState.plate:
          canvas.drawRect(
            Rect.fromCircle(center: offset, radius: size * 1.2 + 0.2),
            Paint()..color = Colors.black.withOpacity(opacity)
          );

          canvas.drawRect(
            Rect.fromCircle(center: offset, radius: size * 1.2),
            Paint()..color = getColor().withOpacity(opacity)
          );
          break;
        case FactoryMaterialState.gear:
          double _bigCircleSize = size * 0.8;
          double _smallCircleSize = size * 0.6;

          Path _gear = Path();

          canvas.save();
          canvas.translate(offset.dx, offset.dy);

          _gear.moveTo(sin(pi * 2) * _smallCircleSize, cos(pi * 2) * _smallCircleSize);

          for(int i = 0; i <= 32; i++){
            double _size = i % 2 == 0 ? _smallCircleSize : _bigCircleSize;
            _gear.lineTo(sin((i/32) * pi * 2) * _size, cos((i/32) * pi * 2) * _size);
          }

          canvas.drawCircle(Offset(0.0, 0.0), size / 2, Paint()..color = getColor().withOpacity(opacity)..style = PaintingStyle.stroke..strokeWidth = 4.0);
          canvas.drawPath(_gear, Paint()..color = getColor().withOpacity(opacity)..strokeWidth = 1.6..style = PaintingStyle.stroke);

          canvas.restore();

          break;
        case FactoryMaterialState.spring:
          final Path _spring = Path();

          double _size = size * 0.6;

          _spring.addPolygon(<Offset>[
            offset + Offset(-_size, -_size),
            offset + Offset(_size, -_size),
            offset + Offset(-_size, -_size * 0.8),
            offset + Offset(_size, -_size * 0.6),
            offset + Offset(-_size, -_size * 0.4),
            offset + Offset(_size, -_size * 0.2),

            offset + Offset(-_size, 0.0),

            offset + Offset(_size, _size * 0.2),
            offset + Offset(-_size, _size * 0.4),
            offset + Offset(_size, _size * 0.6),
            offset + Offset(-_size, _size * 0.8),

            offset + Offset(_size, _size),
            offset + Offset(-_size, _size),
          ], false);

          canvas.drawPath(_spring, Paint()..color = getColor().withOpacity(opacity)..strokeWidth = 0.6..style = PaintingStyle.stroke);
          break;
        case FactoryMaterialState.fluid:
          // TODO: Handle this case.
          break;
        case FactoryMaterialState.raw:
        case FactoryMaterialState.crafted:
        default:
          canvas.drawRect(
            Rect.fromCircle(center: offset, radius: size * 0.6 + 0.2),
            Paint()..color = Colors.black.withOpacity(opacity)
          );

          canvas.drawRect(
            Rect.fromCircle(center: offset, radius: size * 0.6),
            Paint()..color = getColor().withOpacity(opacity)
          );
          break;
      }

      return;
    }

    canvas.drawRect(
      Rect.fromCircle(center: offset, radius: size * 0.6 + 0.2),
      Paint()..color = Colors.black.withOpacity(opacity)
    );

    canvas.drawRect(
      Rect.fromCircle(center: offset, radius: size * 0.6),
      Paint()..color = getColor().withOpacity(opacity)
    );
  }
}

enum FactoryMaterialState{
  raw, plate, gear, spring, fluid, crafted
}

enum FactoryMaterialType{
  iron,
  copper,
  diamond,
  gold,
  aluminium,


  computerChip,
  processor
}

class FactoryRecipe{
  FactoryRecipe(this.recipe);

  final Map<FactoryRecipeMaterialType, int> recipe;
}

class FactoryRecipeMaterialType{
  FactoryMaterialType materialType;
  FactoryMaterialState state;

  FactoryRecipeMaterialType(this.materialType, {this.state = FactoryMaterialState.raw});
}