import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';

abstract class FactoryEquipmentModel{
  FactoryEquipmentModel(this.coordinates, this.direction, this.type, {this.tickDuration = 1});

  FactoryEquipmentModel copyWith({Coordinates coordinates, Direction direction});

  Coordinates coordinates;
  Direction direction;
  EquipmentType type;

  final Map<Direction, int> inputDirections = <Direction, int>{};

  int tickDuration;
  int counter = 0;

  final List<FactoryMaterialModel> objects = <FactoryMaterialModel>[];

  void input(FactoryMaterialModel m){
    final Direction d = Direction.values[(m.direction.index + 2) % Direction.values.length];

    if(!inputDirections.containsKey(d)){
      inputDirections[d] = counter;
    }else{
      inputDirections.addAll(<Direction, int>{
        d: 0
      });
    }

    if(inputDirections[d] < (counter - 100)){
      inputDirections.remove(d);
    }

    if(objects.length > 1000){
      objects.removeRange(0, objects.length - 900);
    }

    objects.add(m);
  }

  Offset get pointingOffset{
    Offset o;

    switch(direction){
      case Direction.west:
        o = Offset(coordinates.x - 1.0, coordinates.y.toDouble());
        break;
      case Direction.east:
        o = Offset(coordinates.x + 1.0, coordinates.y.toDouble());
        break;
      case Direction.south:
        o = Offset(coordinates.x.toDouble(), coordinates.y - 1.0);
        break;
      case Direction.north:
        o = Offset(coordinates.x.toDouble(), coordinates.y + 1.0);
        break;
    }

    return o;
  }

  List<FactoryMaterialModel> tick();

  List<FactoryMaterialModel> equipmentTick(){
    counter++;
    return tick();
  }

  void drawEquipment(Offset offset, Canvas canvas, double size, double progress){}

  void drawTrack(Offset offset, Canvas canvas, double size, double progress){
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    drawSplitter(direction, canvas, size, progress);
//    inputDirections.keys.forEach((Direction d) => drawSplitter(d, canvas, size, progress));

    canvas.restore();
  }

  void drawSplitter(Direction d, Canvas canvas, double size, double progress, {bool entry = false}){
    switch(d){
      case Direction.west:
        canvas.drawRect(Rect.fromCircle(center: Offset(-size / 3, 0.0), radius: size / 3), Paint()..color = Colors.grey.shade800);
        for(int i = 0; i < 4; i++){
          double _xOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
          canvas.drawLine(Offset(_xOffset - size / 3 - size / 3 + size / 6, size / 3), Offset(_xOffset - size / 3 - size / 3 + size / 6, -size / 3), Paint()..color = Colors.white70);
        }
        break;
      case Direction.east:
        canvas.drawRect(Rect.fromCircle(center: Offset(size / 3, 0.0), radius: size / 3), Paint()..color = Colors.grey.shade800);
        for(int i = 0; i < 4; i++){
          double _xOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
          canvas.drawLine(Offset(_xOffset - size / 3 + size / 3 + size / 6, size / 3), Offset(_xOffset - size / 3 + size / 3 + size / 6, -size / 3), Paint()..color = Colors.white70);
        }
        break;
      case Direction.south:
        canvas.drawRect(Rect.fromCircle(center: Offset(0.0, -size / 3), radius: size / 3), Paint()..color = Colors.grey.shade800);
        for(int i = 0; i < 4; i++){
          double _yOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
          canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3 + size / 6), Offset(-size / 3, _yOffset - size / 3 - size / 3 + size / 6), Paint()..color = Colors.white70);
        }
        break;
      case Direction.north:
        canvas.drawRect(Rect.fromCircle(center: Offset(0.0, size / 3), radius: size / 3), Paint()..color = Colors.grey.shade800);
        for(int i = 0; i < 4; i++){
          double _yOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
          canvas.drawLine(Offset(size / 3, _yOffset + size / 3 - size / 3 + size / 6), Offset(-size / 3, _yOffset + size / 3 - size / 3 + size / 6), Paint()..color = Colors.white70);
        }
        break;
    }
  }

  void drawRoller(Direction d, Canvas canvas, double size, double progress){
    switch(d){
      case Direction.east:
        canvas.drawRect(Rect.fromPoints(
          Offset(size / 1.7, -size / 3),
          Offset(size / 3, size / 3)
        ), Paint()..color = Colors.grey);
        for(int i = 0; i < 3; i++){
          final double _xOffset = i * (size / 8);
          canvas.drawLine(Offset(size / 1.7 - _xOffset, size / 3), Offset(size / 1.7 - _xOffset, -size / 3), Paint()..color = Colors.grey.shade800..strokeWidth = 2.2);
        }
        break;
      case Direction.west:
        canvas.drawRect(Rect.fromPoints(
          Offset(-size / 1.7, -size / 3),
          Offset(-size / 3, size / 3)
        ), Paint()..color = Colors.grey);
        for(int i = 0; i < 3; i++){
          double _xOffset = i * (size / 8);
          canvas.drawLine(Offset(_xOffset - size / 1.7, size / 3), Offset(_xOffset - size / 1.7, -size / 3), Paint()..color = Colors.grey.shade800..strokeWidth = 2.2);
        }
        break;
      case Direction.south:
        canvas.drawRect(Rect.fromPoints(
          Offset(size / 3, -size / 3),
          Offset(-size / 3, -size / 1.7)
        ), Paint()..color = Colors.grey);
        for(int i = 0; i < 3; i++){
          double _yOffset = i * (size / 8);
          canvas.drawLine(Offset(size / 3, _yOffset - size / 1.7), Offset(-size / 3, _yOffset - size / 1.7), Paint()..color = Colors.grey.shade800..strokeWidth = 2.2);
        }
        break;
      case Direction.north:
        canvas.drawRect(Rect.fromPoints(
          Offset(size / 3, size / 3),
          Offset(-size / 3, size / 1.7)
        ), Paint()..color = Colors.grey);
        for(int i = 0; i < 3; i++){
          double _yOffset = i * (size / 8);
          canvas.drawLine(Offset(size / 3, size / 1.7 - _yOffset), Offset(-size / 3, size / 1.7 - _yOffset), Paint()..color = Colors.grey.shade800..strokeWidth = 2.2);
        }
        break;
    }
  }

  void drawMaterial(Offset offset, Canvas canvas, double size, double progress){
    double _moveX = 0.0;
    double _moveY = 0.0;

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

    objects.forEach((FactoryMaterialModel fm){
      fm.drawMaterial(offset + Offset(fm.offsetX + _moveX, fm.offsetY + _moveY), canvas, progress);
    });
  }

  void paintInfo(Offset offset, Canvas canvas, double size, double progress){
    double x = offset.dx;
    double y = offset.dy;

    Paint _p = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0;

    switch(direction){
      case Direction.east:{
        canvas.drawLine(
          Offset(x - size / 2.2, y),
          Offset(x + size / 2.2, y),
          _p
        );
        canvas.drawLine(
          Offset(x + size / 2.2, y),
          Offset(x, y + size / 2.5),
          _p
        );
        canvas.drawLine(
          Offset(x + size / 2.2, y),
          Offset(x, y - size / 2.5),
          _p
        );
        break;
      }
      case Direction.west:{
        canvas.drawLine(
          Offset(x - size / 2.2, y),
          Offset(x + size / 2.2, y),
          _p
        );
        canvas.drawLine(
          Offset(x - size / 2.2, y),
          Offset(x, y + size / 2.5),
          _p
        );
        canvas.drawLine(
          Offset(x - size / 2.2, y),
          Offset(x, y - size / 2.5),
          _p
        );
        break;
      }
      case Direction.south:{
        canvas.drawLine(
          Offset(x, y - size / 2.2),
          Offset(x, y + size / 2.2),
          _p
        );
        canvas.drawLine(
          Offset(x - size / 2.5, y),
          Offset(x, y - size / 2.2),
          _p
        );
        canvas.drawLine(
          Offset(x + size / 2.5, y),
          Offset(x, y - size / 2.2),
          _p
        );
        break;
      }
      case Direction.north:{
        canvas.drawLine(
          Offset(x, y - size / 2.2),
          Offset(x, y + size / 2.2),
          _p
        );
        canvas.drawLine(
          Offset(x - size / 2.5, y),
          Offset(x, y + size / 2.2),
          _p
        );
        canvas.drawLine(
          Offset(x + size / 2.5, y),
          Offset(x, y + size / 2.2),
          _p
        );
        break;
      }
      default:
        break;
    }
  }

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      'equipment_type': type.index,
      'position': coordinates.toMap(),
      'direction': direction.index,
      'tick_duration': tickDuration,
      'material': objects.map((FactoryMaterialModel fmm) => fmm.toMap()).toList()
    };
  }
}

enum Direction{
  south, east, north, west
}

enum EquipmentType{
  dispenser, roller, freeRoller, crafter, splitter, sorter, seller, hydraulic_press, wire_bender, cutter, melter, portal
}

String directionToString(Direction d){
  switch(d){
    case Direction.south:
      return '↑';
    case Direction.east:
      return '→';
    case Direction.north:
      return '↓';
    case Direction.west:
      return '←';
    default:
      return '';
  }
}

String equipmentTypeToString(EquipmentType type){
  switch(type){
    case EquipmentType.dispenser: return 'Dispenser';
    case EquipmentType.roller: return 'Roller';
    case EquipmentType.freeRoller: return 'Free roller';
    case EquipmentType.crafter: return 'Crafter';
    case EquipmentType.splitter: return 'Splitter';
    case EquipmentType.sorter: return 'Sorter';
    case EquipmentType.seller: return 'Seller';
    case EquipmentType.hydraulic_press: return 'Hydraulic press';
    case EquipmentType.wire_bender: return 'Wire bender';
    case EquipmentType.cutter: return 'Cutter';
    case EquipmentType.melter: return 'Melter';
    case EquipmentType.portal: return 'Portal';
  }

  return '';
}

String equipmentDescriptionFromType(EquipmentType type){
  switch(type){
    case EquipmentType.dispenser: return 'Dispenses new raw material that can be processed, crafted or sold.';
    case EquipmentType.roller: return 'Moves material in selected direction.';
    case EquipmentType.freeRoller: return 'Moves material but it won\'t change it\'s direction.';
    case EquipmentType.crafter: return 'Crafter can craft new more complicated materials.';
    case EquipmentType.splitter: return 'Splits incoming materials to all selected directions equally. Multiples of same direction can be set.';
    case EquipmentType.sorter: return 'It can move specific material in any direction, it has \'default\' exit where any other material will exit.';
    case EquipmentType.seller: return 'Sells material for profit.';
    case EquipmentType.hydraulic_press: return 'Press raw material to make plates.';
    case EquipmentType.wire_bender: return 'Bend raw material to make springs.';
    case EquipmentType.cutter: return 'Cut raw material to make gears.';
    case EquipmentType.melter: return 'Melt raw material to get liquid.';
    case EquipmentType.portal: return 'Underground roller tunnel entry/exit.';
  }

  return '';
}