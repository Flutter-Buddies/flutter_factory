import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/craftables/battery.dart';
import 'package:flutter_factory/game/craftables/clock.dart';
import 'package:flutter_factory/game/craftables/computer_chip.dart';
import 'package:flutter_factory/game/craftables/cooler_plate.dart';
import 'package:flutter_factory/game/craftables/drone.dart';
import 'package:flutter_factory/game/craftables/engine.dart';
import 'package:flutter_factory/game/craftables/heater_plate.dart';
import 'package:flutter_factory/game/craftables/light_bulb.dart';
import 'package:flutter_factory/game/craftables/processor.dart';
import 'package:flutter_factory/game/craftables/railway.dart';
import 'package:flutter_factory/game/material/aluminium.dart';
import 'package:flutter_factory/game/material/copper.dart';
import 'package:flutter_factory/game/material/diamond.dart';
import 'package:flutter_factory/game/material/gold.dart';
import 'package:flutter_factory/game/material/iron.dart';

import 'factory_equipment.dart';

abstract class FactoryMaterial{
  FactoryMaterial(this.x, this.y, this.value, this.type, {this.size = 8.0, this.state = FactoryMaterialState.raw}) : rotation = Random().nextDouble() * pi, offsetX = Random().nextDouble() * 14 - 7, offsetY = Random().nextDouble() * 14 - 7;

  double x;
  double y;

  double size;
  Direction direction;

  final double value;
  final double offsetX;
  final double offsetY;
  final double rotation;

  final FactoryMaterialType type;

  FactoryMaterialState state;

  final Map<FactoryMaterialType, List<FactoryMaterialHistory>> _history = <FactoryMaterialType, List<FactoryMaterialHistory>>{};

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
      case FactoryMaterialType.engine:
        return Engine.fromOffset(offset);
      case FactoryMaterialType.heaterPlate:
        return HeaterPlate.fromOffset(offset);
      case FactoryMaterialType.coolerPlate:
        return CoolerPlate.fromOffset(offset);
      case FactoryMaterialType.lightBulb:
        return LightBulb.fromOffset(offset);
      case FactoryMaterialType.clock:
        return Clock.fromOffset(offset);
      case FactoryMaterialType.railway:
        return Railway.fromOffset(offset);
      case FactoryMaterialType.battery:
        return Battery.fromOffset(offset);
      case FactoryMaterialType.drone:
        return Drone.fromOffset(offset);
    }

    return null;
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

  // TODO: Add this to log history of the material travel
  void logHistory(FactoryEquipment equipment){
    if(_history.containsKey(type)){
      _history[type].add(FactoryMaterialHistory(state: state, position: Offset(equipment.coordinates.x.toDouble(), equipment.coordinates.y.toDouble())));
    }else{
      _history.addAll(<FactoryMaterialType, List<FactoryMaterialHistory>>{
        type: <FactoryMaterialHistory>[
          FactoryMaterialHistory(state: state, position: Offset(x, y))
        ]
      });
    }
  }

  void moveMaterial(){
    switch(direction){
      case Direction.west:
        x -= 1.0;
        break;
      case Direction.east:
        x += 1.0;
        break;
      case Direction.south:
        y -= 1.0;
        break;
      case Direction.north:
        y += 1.0;
        break;
    }
  }
  
  Map<FactoryRecipeMaterialType, int> getRecipe(){
    return <FactoryRecipeMaterialType, int>{};
  }

  static Map<FactoryRecipeMaterialType, int> getRecipeFromType(FactoryMaterialType type){
    return FactoryMaterial.getFromType(type).getRecipe();
  }

  static bool isRaw(FactoryMaterialType type){
    return type.index <= FactoryMaterialType.aluminium.index;
  }

  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    if(isRawMaterial && state != FactoryMaterialState.raw){
      switch(state){
        case FactoryMaterialState.plate:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCircle(center: offset, radius: size * 1.2 + 0.2),
              Radius.circular(size * 0.3)
            ),
            Paint()..color = Colors.black.withOpacity(opacity)
          );

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCircle(center: offset, radius: size * 1.2),
              Radius.circular(size * 0.3)
            ),
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
            double _size = i % 4 >= 2 ? _smallCircleSize : _bigCircleSize;
            _gear.lineTo(sin((i/32) * pi * 2) * _size, cos((i/32) * pi * 2) * _size);
          }

          canvas.drawCircle(Offset.zero, size / 2, Paint()..color = getColor().withOpacity(opacity)..style = PaintingStyle.stroke..strokeWidth = 3.8);
          canvas.drawPath(_gear, Paint()..color = getColor().withOpacity(opacity)..strokeWidth = 1.6..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round);

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
          final double _size = size * 0.6;

          final Path _fluidPath = Path();

          canvas.save();
          canvas.translate(offset.dx, offset.dy);

          _fluidPath.moveTo(_size * 0.6, _size);
          _fluidPath.lineTo(-_size * 0.6, _size);

          _fluidPath.arcToPoint(Offset(-_size, _size * 0.5), radius: Radius.circular(_size * 0.4));

          _fluidPath.lineTo(-_size * 0.3, -_size * 0.4);
          _fluidPath.lineTo(_size * 0.3, -_size * 0.4);

          _fluidPath.lineTo(_size, _size * 0.5);
          _fluidPath.arcToPoint(Offset(_size * 0.6, _size), radius: Radius.circular(_size * 0.4));


          final Path _flaskPath = Path();

          _flaskPath.moveTo(_size * 0.7, _size);
          _flaskPath.lineTo(-_size * 0.7, _size);

          _flaskPath.arcToPoint(Offset(-_size, _size * 0.5), radius: Radius.circular(_size * 0.4));

          _flaskPath.lineTo(-_size * 0.3, -_size * 0.4);
          _flaskPath.lineTo(-_size * 0.3, -_size * 0.9);
          _flaskPath.lineTo(_size * 0.3, -_size * 0.9);
          _flaskPath.lineTo(_size * 0.3, -_size * 0.4);

          _flaskPath.lineTo(_size, _size * 0.6);
          _flaskPath.arcToPoint(Offset(_size * 0.7, _size), radius: Radius.circular(_size * 0.3));

          _flaskPath.moveTo(_size * 0.5, -_size * 0.9);
          _flaskPath.lineTo(-_size * 0.5, -_size * 0.9);

          canvas.drawPath(_fluidPath, Paint()..color = getColor().withOpacity(opacity)..style = PaintingStyle.fill..strokeJoin = StrokeJoin.round);
          canvas.drawPath(_flaskPath, Paint()..color = Colors.black.withOpacity(opacity)..strokeWidth = 0.6..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);

          canvas.restore();
          break;
        case FactoryMaterialState.raw:
        case FactoryMaterialState.crafted:
        default:
          canvas.drawRect(
            Rect.fromCircle(center: offset, radius: size * 0.5 + 0.2),
            Paint()..color = Colors.black.withOpacity(opacity)
          );

          canvas.drawRect(
            Rect.fromCircle(center: offset, radius: size * 0.5),
            Paint()..color = getColor().withOpacity(opacity)
          );
          break;
      }

      return;
    }

    canvas.drawRect(
      Rect.fromCircle(center: offset, radius: size * 0.5 + 0.2),
      Paint()..color = Colors.black.withOpacity(opacity)
    );

    canvas.drawRect(
      Rect.fromCircle(center: offset, radius: size * 0.5),
      Paint()..color = getColor().withOpacity(opacity)
    );
  }
}

class FactoryMaterialHistory{
  FactoryMaterialHistory({
    this.state,
    this.position,
  });

  final FactoryMaterialState state;
  final Offset position;

  final Map<FactoryMaterialType, List<FactoryMaterialHistory>> craftedFrom = <FactoryMaterialType, List<FactoryMaterialHistory>>{};
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
  processor,
  engine,
  heaterPlate,
  coolerPlate,
  lightBulb,
  clock,
  railway,
  battery,
  drone
}

class FactoryRecipe{
  FactoryRecipe(this.recipe);

  final Map<FactoryRecipeMaterialType, int> recipe;
}

class FactoryRecipeMaterialType{
  FactoryRecipeMaterialType(this.materialType, {FactoryMaterialState state}) : state = state ?? (FactoryMaterial.isRaw(materialType) ? FactoryMaterialState.raw : FactoryMaterialState.crafted);

  final FactoryMaterialType materialType;
  final FactoryMaterialState state;
}