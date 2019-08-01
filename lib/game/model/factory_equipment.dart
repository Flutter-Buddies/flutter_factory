import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

abstract class FactoryEquipment{
  FactoryEquipment(this.coordinates, this.direction, this.type, {this.tickDuration = 1});

  FactoryEquipment copyWith({Coordinates coordinates, Direction direction});

  Coordinates coordinates;
  Direction direction;
  EquipmentType type;

  final Map<Direction, int> inputDirections = <Direction, int>{};

  int tickDuration;
  int counter = 0;

  final List<FactoryMaterial> objects = <FactoryMaterial>[];

  void input(FactoryMaterial m){
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

  List<FactoryMaterial> tick();

  List<FactoryMaterial> equipmentTick(){
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
        for(int i = 0; i < 3; i++){
          double _xOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 2);
          canvas.drawLine(Offset(_xOffset - size / 3 - size / 3 + size / 6, size / 3), Offset(_xOffset - size / 3 - size / 3 + size / 6, -size / 3), Paint()..color = Colors.white70);
        }
        break;
      case Direction.east:
        canvas.drawRect(Rect.fromCircle(center: Offset(size / 3, 0.0), radius: size / 3), Paint()..color = Colors.grey.shade800);
        for(int i = 0; i < 3; i++){
          double _xOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 2);
          canvas.drawLine(Offset(_xOffset - size / 3 + size / 3 + size / 6, size / 3), Offset(_xOffset - size / 3 + size / 3 + size / 6, -size / 3), Paint()..color = Colors.white70);
        }
        break;
      case Direction.south:
        canvas.drawRect(Rect.fromCircle(center: Offset(0.0, -size / 3), radius: size / 3), Paint()..color = Colors.grey.shade800);
        for(int i = 0; i < 3; i++){
          double _yOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 2);
          canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3 + size / 6), Offset(-size / 3, _yOffset - size / 3 - size / 3 + size / 6), Paint()..color = Colors.white70);
        }
        break;
      case Direction.north:
        canvas.drawRect(Rect.fromCircle(center: Offset(0.0, size / 3), radius: size / 3), Paint()..color = Colors.grey.shade800);
        for(int i = 0; i < 3; i++){
          double _yOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 2);
          canvas.drawLine(Offset(size / 3, _yOffset + size / 3 - size / 3 + size / 6), Offset(-size / 3, _yOffset + size / 3 - size / 3 + size / 6), Paint()..color = Colors.white70);
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

    objects.reversed.forEach((FactoryMaterial fm){
      fm.drawMaterial(offset + Offset(fm.offsetX + _moveX, fm.offsetY + _moveY), canvas, progress);
    });
  }

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      'equipment_type': type.index,
      'position_x': coordinates.x,
      'position_y': coordinates.y,
      'direction': direction.index,
      'tick_duration': tickDuration
    };
  }
}

enum Direction{
  south, east, north, west
}

enum EquipmentType{
  dispenser, roller, crafter, splitter, sorter, seller, hydraulic_press, wire_bender, cutter
}