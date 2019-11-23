import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/ui/theme/game_theme.dart';

abstract class FactoryEquipmentModel{
  FactoryEquipmentModel(this.coordinates, this.direction, this.type, {this.tickDuration = 1, this.isMutable = true});

  /// Copy factory equipment as new entity.
  /// This allows for moving and coping equipment around
  FactoryEquipmentModel copyWith({Coordinates coordinates, Direction direction});

  Coordinates coordinates;
  Direction direction;
  EquipmentType type;

  final bool isMutable;

  /// Directions from where new material is coming from.
  ///
  /// It will remember material for 100 ticks before dropping direction as active
  final Map<Direction, int> inputDirections = <Direction, int>{};

  /// Equipment tickDuration, or how long does it take to process material and send it to next
  /// square. Next square will be found from [direction] of the equipment.
  ///
  /// The [direction] can be changed,
  int tickDuration;
  int counter = 0;

  final List<FactoryMaterialModel> objects = <FactoryMaterialModel>[];

  void input(FactoryMaterialModel m){
    final Direction d = Direction.values[(m.direction.index + 2) % Direction.values.length];

    inputDirections[d] = counter;

    inputDirections.removeWhere((Direction _d, int _count) => _count < (counter - 10));

//    print('Input: ${equipmentTypeToString(type)} - ${inputDirections.keys.fold('', (String s, Direction d) => s += directionToString(d))}');

    if(objects.length > 1000){
      objects.removeRange(0, objects.length - 900);
    }

    objects.add(m);
  }

  /// Get offset where material should go.
  ///
  /// This is used by [Dispenser] and [Crafter] to make new materials
  /// at their exit points.
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

  /// Tick is when one tick has passed, all equipment should return materials they want to send to next equipment.
  ///
  /// If no materials can be forwarded then pass empty array
  /// This is overridden by any new equipment, it will set how the equipment behaves on tick
  List<FactoryMaterialModel> tick();

  /// Trigger equipment tick from [GameBloc] where material will be forwarded to next
  /// equipment in the line or will be added to excess material list (factory floor) that will disappear after few ticks
  ///
  /// Increases equipment counter, counter is used to determine if equipments [tickDuration] has passed
  List<FactoryMaterialModel> equipmentTick(){
    counter++;
    return tick();
  }

  /// Draws equipment on the canvas
  ///
  /// Empty since some equipment doesn't need anything extra to show like [Roller], [Splitter] or [FreeRoller]
  void drawEquipment(GameTheme theme, Offset offset, Canvas canvas, double size, double progress){}

  void drawTrack(GameTheme theme, Offset offset, Canvas canvas, double size, double progress){
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    drawSplitter(theme, direction, canvas, size, progress);

    canvas.restore();
  }

  void drawSplitter(GameTheme theme, Direction d, Canvas canvas, double size, double progress, {bool entry = false}){
    switch(d){
      case Direction.west:
        canvas.drawRect(Rect.fromCircle(center: Offset(-size / 3, 0.0), radius: size / 3), Paint()..color = theme.rollersColor);
        for(int i = 0; i < 4; i++){
          double _xOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
          canvas.drawLine(Offset(_xOffset - size / 3 - size / 3 + size / 6, size / 3), Offset(_xOffset - size / 3 - size / 3 + size / 6, -size / 3), Paint()..color = theme.rollerDividersColor);
        }
        break;
      case Direction.east:
        canvas.drawRect(Rect.fromCircle(center: Offset(size / 3, 0.0), radius: size / 3), Paint()..color = theme.rollersColor);
        for(int i = 0; i < 4; i++){
          double _xOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
          canvas.drawLine(Offset(_xOffset - size / 3 + size / 3 + size / 6, size / 3), Offset(_xOffset - size / 3 + size / 3 + size / 6, -size / 3), Paint()..color = theme.rollerDividersColor);
        }
        break;
      case Direction.south:
        canvas.drawRect(Rect.fromCircle(center: Offset(0.0, -size / 3), radius: size / 3), Paint()..color = theme.rollersColor);
        for(int i = 0; i < 4; i++){
          double _yOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
          canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3 + size / 6), Offset(-size / 3, _yOffset - size / 3 - size / 3 + size / 6), Paint()..color = theme.rollerDividersColor);
        }
        break;
      case Direction.north:
        canvas.drawRect(Rect.fromCircle(center: Offset(0.0, size / 3), radius: size / 3), Paint()..color = theme.rollersColor);
        for(int i = 0; i < 4; i++){
          double _yOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
          canvas.drawLine(Offset(size / 3, _yOffset + size / 3 - size / 3 + size / 6), Offset(-size / 3, _yOffset + size / 3 - size / 3 + size / 6), Paint()..color = theme.rollerDividersColor);
        }
        break;
    }
  }

  /// TODO: Remove progress from here, it is not needed!
  void drawRoller(GameTheme theme, Direction d, Canvas canvas, double size, double progress){
    switch(d){
      case Direction.east:
        for(int i = 0; i < 6; i++){
          final double _xOffset = i * (size / 8);
          canvas.drawLine(Offset(size / 2 + size / 6 - _xOffset, size / 3), Offset(size / 2 + size / 6 - _xOffset, -size / 3), Paint()..color = theme.rollersColor..strokeWidth = 2.2);
        }
        break;
      case Direction.west:
        for(int i = 0; i < 6; i++){
          double _xOffset = i * (size / 8);
          canvas.drawLine(Offset(-size / 2 - size / 6 + _xOffset, size / 3), Offset(-size / 2 - size / 6 + _xOffset, -size / 3), Paint()..color = theme.rollersColor..strokeWidth = 2.2);
        }
        break;
      case Direction.south:
        for(int i = 0; i < 6; i++){
          double _yOffset = i * (size / 8);
          canvas.drawLine(Offset(size / 3, _yOffset - size / 2 - size / 6), Offset(-size / 3, _yOffset - size / 2 - size / 6), Paint()..color = theme.rollersColor..strokeWidth = 2.2);
        }
        break;
      case Direction.north:
        for(int i = 0; i < 6; i++){
          double _yOffset = i * (size / 8);
          canvas.drawLine(Offset(size / 3, size / 2 + size / 6 - _yOffset), Offset(-size / 3, size / 2 + size / 6 - _yOffset), Paint()..color = theme.rollersColor..strokeWidth = 2.2);
        }
        break;
    }
  }

  /// Draw material that is leaving the equipment
  /// TODO: Save directions to temp variable that will only change on tick?
  void drawMaterial(GameTheme theme, Offset offset, Canvas canvas, double size, double progress){
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

  /// Show equipment info (arrows) and other useful information
  void paintInfo(GameTheme theme, Offset offset, Canvas canvas, double size, double progress){
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
      'is_mutable': isMutable,
      'material': objects.getRange(max(0, objects.length - 50), objects.length).map((FactoryMaterialModel fmm) => fmm.toMap()).toList()
    };
  }
}

enum Direction{
  south, east, north, west
}

enum EquipmentType{
  dispenser, roller, freeRoller, crafter, splitter, sorter, seller, hydraulic_press, wire_bender, cutter, melter, rotatingFreeRoller, portal
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
    case EquipmentType.rotatingFreeRoller: return 'Rotating free roller';
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
    case EquipmentType.rotatingFreeRoller: return 'Will rotate any material that comes in for 90 deg';
    case EquipmentType.portal: return 'Will transfer material underground, automatically connects to other portal enterance';
  }

  return '';
}