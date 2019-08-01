import 'dart:async';
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter_factory/debug/track_builder.dart';
import 'package:flutter_factory/game/equipment/crafter.dart';
import 'package:flutter_factory/game/equipment/roller.dart';
import 'package:flutter_factory/game/equipment/seller.dart';
import 'package:flutter_factory/game/equipment/sorter.dart';
import 'package:flutter_factory/game/equipment/splitter.dart';
import 'package:flutter_factory/game/equipment/dispenser.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_material.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:rxdart/rxdart.dart';

import 'game/equipment/cutter.dart';
import 'game/equipment/hydraulic_press.dart';
import 'game/equipment/wire_bender.dart';

enum GameWindows{
  buy, settings
}

class GameBloc{
  GameBloc(){
    _waitForTick();
    _equipment.addAll(buildStressTestChipProduction());
  }

  Duration _duration = Duration();
  int _lastTrigger = -1;
  
  int _tickSpeed = 1024;
  bool showArrows = false;

  GameWindows currentWindow = GameWindows.buy;
  EquipmentType buildSelectedEquipmentType = EquipmentType.roller;
  Direction buildSelectedEquipmentDirection = Direction.south;

  List<Coordinates> selectedTiles = <Coordinates>[];

  void increaseGameSpeed() => _tickSpeed = (_tickSpeed * 0.5).round();
  void decreaseGameSpeed() => _tickSpeed *= 2;

  String get gameSpeed => '$_tickSpeed ms';

  double get progress => _duration.inMilliseconds ~/ _tickSpeed == _lastTrigger ~/ _tickSpeed ? (_duration.inMilliseconds / _tickSpeed) % 1 : 1.0;

  void _waitForTick() async {
    final int _start = DateTime.now().millisecondsSinceEpoch;
    await SchedulerBinding.instance.endOfFrame;
    _tick();
    _duration += Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - _start);
    _waitForTick();
  }

  void addEquipment(FactoryEquipment equipment){
    _equipment.add(equipment);
    _gameUpdate.add(GameUpdate.addEquipment);
  }

  void buildSelected(){
    void _addEquipment(FactoryEquipment e){
      selectedTiles.forEach((Coordinates c){
        _equipment.add(e.copyWith(coordinates: c));
      });
    }

    switch(buildSelectedEquipmentType){
      case EquipmentType.dispenser:
        _addEquipment(Dispenser(Coordinates(0, 0), buildSelectedEquipmentDirection, FactoryMaterialType.iron));
        break;
      case EquipmentType.roller:
        _addEquipment(Roller(Coordinates(0, 0), buildSelectedEquipmentDirection));
        break;
      case EquipmentType.crafter:
        _addEquipment(Crafter(Coordinates(0, 0), buildSelectedEquipmentDirection, FactoryMaterialType.computerChip));
        break;
      case EquipmentType.splitter:
        _addEquipment(Splitter(Coordinates(0, 0), buildSelectedEquipmentDirection, <Direction>[buildSelectedEquipmentDirection]));
        break;
      case EquipmentType.sorter:
        _addEquipment(Sorter(Coordinates(0, 0), buildSelectedEquipmentDirection, <FactoryMaterialType, Direction>{}));
        break;
      case EquipmentType.seller:
        _addEquipment(Seller(Coordinates(0, 0), buildSelectedEquipmentDirection));
        break;
      case EquipmentType.hydraulic_press:
        _addEquipment(HydraulicPress(Coordinates(0, 0), buildSelectedEquipmentDirection));
        break;
      case EquipmentType.wire_bender:
        _addEquipment(WireBender(Coordinates(0, 0), buildSelectedEquipmentDirection));
        break;
      case EquipmentType.cutter:
        _addEquipment(Cutter(Coordinates(0, 0), buildSelectedEquipmentDirection));
        break;
    }
  }

  FactoryEquipment previewEquipment(EquipmentType type){
    switch(type){
      case EquipmentType.dispenser:
        return Dispenser(selectedTiles.first, buildSelectedEquipmentDirection, FactoryMaterialType.iron);
      case EquipmentType.roller:
        return Roller(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.crafter:
        return Crafter(selectedTiles.first, buildSelectedEquipmentDirection, FactoryMaterialType.computerChip);
      case EquipmentType.splitter:
        return Splitter(selectedTiles.first, buildSelectedEquipmentDirection, <Direction>[buildSelectedEquipmentDirection]);
      case EquipmentType.sorter:
        return Sorter(selectedTiles.first, buildSelectedEquipmentDirection, <FactoryMaterialType, Direction>{});
      case EquipmentType.seller:
        return Seller(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.hydraulic_press:
        return HydraulicPress(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.wire_bender:
        return WireBender(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.cutter:
        return Cutter(selectedTiles.first, buildSelectedEquipmentDirection);
    }

    return null;
  }

  List<FactoryMaterial> get getExcessMaterial => _excessMaterial.fold(<FactoryMaterial>[], (List<FactoryMaterial> _folded, List<FactoryMaterial> _m) => _folded..addAll(_m)).toList();
  List<FactoryMaterial> get getLastExcessMaterial => _excessMaterial.first;
  List<FactoryEquipment> get equipment => _equipment;

  void _tick(){
    List<FactoryMaterial> _material;

    if(_duration.inMilliseconds ~/ _tickSpeed == _lastTrigger ~/ _tickSpeed){
      _material = _equipment.fold(<FactoryMaterial>[], (List<FactoryMaterial> _material, FactoryEquipment e) => _material..addAll(e.objects));
    }else{
      _material = _equipment.fold(<FactoryMaterial>[], (List<FactoryMaterial> _material, FactoryEquipment e) => _material..addAll(e.equipmentTick()));
      _lastTrigger = _duration.inMilliseconds;

      if(_excessMaterial.length > _excessMaterialCleanup){
        _excessMaterial.removeAt(0);
      }

      final List<FactoryMaterial> _excess = <FactoryMaterial>[];

      _material.forEach((FactoryMaterial fm){
        FactoryEquipment _e = _equipment.firstWhere((FactoryEquipment fe) => fe.coordinates.x == fm.x.floor() && fe.coordinates.y == fm.y.floor(), orElse: () => null);
        if(_e != null){
          _e.input(fm);
        }else{
          _excess.add(fm);
        }
      });

      _excessMaterial.add(_excess);
    }

    _gameUpdate.add(GameUpdate.tick);
  }

  void changeWindow(GameWindows window){
    currentWindow = window;
    _gameUpdate.add(GameUpdate.windowChange);
  }

  final List<FactoryEquipment> _equipment = <FactoryEquipment>[];
  final List<List<FactoryMaterial>> _excessMaterial = <List<FactoryMaterial>>[];

  final int _excessMaterialCleanup = 2;

  Stream<GameUpdate> get gameUpdate => _gameUpdate.stream;

  final PublishSubject<GameUpdate> _gameUpdate = PublishSubject<GameUpdate>();

  void dispose(){
    _gameUpdate.close();
  }
}

enum GameUpdate{
  tick, addEquipment, windowChange
}