import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter_factory/game/equipment/crafter.dart';
import 'package:flutter_factory/game/equipment/free_roller.dart';
import 'package:flutter_factory/game/equipment/roller.dart';
import 'package:flutter_factory/game/equipment/seller.dart';
import 'package:flutter_factory/game/equipment/sorter.dart';
import 'package:flutter_factory/game/equipment/splitter.dart';
import 'package:flutter_factory/game/equipment/dispenser.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_material.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'game/equipment/cutter.dart';
import 'game/equipment/hydraulic_press.dart';
import 'game/equipment/melter.dart';
import 'game/equipment/wire_bender.dart';

enum GameWindows{
  buy, settings
}

class GameBloc{
  GameBloc(){
    _waitForTick();
    _loadFactory();
  }

  int _factoryFloor = 0;

  ObjectDB _db;

  Future<ObjectDB> get db async {
    if(_db == null){
      await _openDatabase();
    }

    return _db;
  }

  // TODO: Add better database management in order to add factory floors!
  void changeFloor(int factoryFloor) async {
    if(factoryFloor == _factoryFloor){
      return;
    }
    await _saveFactory();
    _factoryFloor = factoryFloor;
    _loadFactory();
  }

  Future<void> _openDatabase() async {
    final Directory _path = await getApplicationDocumentsDirectory();
    _db = ObjectDB(_path.path + '._factory.db');
    _db.open();
    return;
  }

  void _loadFactory() async {
    print('Loading factory from DB!');

    ObjectDB _dbObject = await db;
    final Map<String, dynamic> _result = await _dbObject.first(<String, int>{'factory_floor': _factoryFloor});

    if(_result == null){
      _saveFactory();
      return;
    }

    print('Got from DB!');


    final List<dynamic> _equipmentList = _result['equipment'];

    print('Loaded equipment: ${_equipmentList.length}');

    _equipment.clear();
    _equipment.addAll(_equipmentList.map((dynamic eq) => _equipmentFromMap(eq)));

    print(_result);
  }

  Future<void> _saveFactory() async {
    ObjectDB _dbObject = await db;
    final Map<String, dynamic> _result = await _dbObject.first(<String, int>{'factory_floor': _factoryFloor});

    if(_result == null){
      await _dbObject.insert(toMap());
    }else{
      await _dbObject.update(<String, int>{'factory_floor': _factoryFloor}, toMap());
    }
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

  int _frameRate = 0;
  int _tickStart = 0;

  List<int> _averageFrameRate = <int>[];

  int get frameRate => _averageFrameRate.fold(0, (int _rate, int _value) => _rate += _value) ~/ _averageFrameRate.length;

  double get progress => _duration.inMilliseconds ~/ _tickSpeed == _lastTrigger ~/ _tickSpeed ? (_duration.inMilliseconds / _tickSpeed) % 1 : 1.0;

  void _waitForTick() async {
    _frameRate = _tickSpeed ~/ (DateTime.now().millisecondsSinceEpoch - _tickStart);
    _averageFrameRate.add(_frameRate);

    if(_averageFrameRate.length > 40){
      _averageFrameRate.removeAt(0);
    }

    _tickStart = DateTime.now().millisecondsSinceEpoch;
    await SchedulerBinding.instance.endOfFrame;
    _tick();
    _duration += Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - _tickStart);
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
        _addEquipment(Sorter(Coordinates(0, 0), buildSelectedEquipmentDirection, <FactoryRecipeMaterialType, Direction>{}));
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
      case EquipmentType.melter:
        _addEquipment(Melter(Coordinates(0, 0), buildSelectedEquipmentDirection));
        break;
      case EquipmentType.freeRoller:
        _addEquipment(FreeRoller(Coordinates(0, 0), buildSelectedEquipmentDirection));
        break;
    }

    _saveFactory();
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
        return Sorter(selectedTiles.first, buildSelectedEquipmentDirection, <FactoryRecipeMaterialType, Direction>{});
      case EquipmentType.seller:
        return Seller(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.hydraulic_press:
        return HydraulicPress(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.wire_bender:
        return WireBender(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.cutter:
        return Cutter(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.melter:
        return Melter(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.freeRoller:
        return FreeRoller(selectedTiles.first, buildSelectedEquipmentDirection);
    }

    return null;
  }

  List<FactoryMaterial> get getExcessMaterial => _excessMaterial.fold(<FactoryMaterial>[], (List<FactoryMaterial> _folded, List<FactoryMaterial> _m) => _folded..addAll(_m)).toList();
  List<FactoryMaterial> get getLastExcessMaterial => _excessMaterial.first;
  List<FactoryEquipment> get equipment => _equipment;
  List<FactoryMaterial> get material => _equipment.map((FactoryEquipment fe) => fe.objects).fold(<FactoryMaterial>[], (List<FactoryMaterial> _fm, List<FactoryMaterial> _em) => _fm..addAll(_em)).toList();

  void clearLine(){
    _equipment.clear();

    _saveFactory();
  }

  void removeEquipment(FactoryEquipment equipment){
    if(_equipment.contains(equipment)){
      _equipment.remove(equipment);

      _saveFactory();
    }
  }

  void loadLine(List<FactoryEquipment> newLine){
    _equipment.clear();
    _equipment.addAll(newLine);

    _saveFactory();
  }

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
    _saveFactory();
    _gameUpdate.close();
  }

  Map<String, dynamic> toMap(){
    final List<String> _equipmentMap = equipment.map((FactoryEquipment fe) => json.encode(fe.toMap())).toList();

    return <String, dynamic>{
      'factory_floor': _factoryFloor,
      'equipment': _equipmentMap
    };
  }


  FactoryEquipment _equipmentFromMap(String jsonMap){
    final Map<String, dynamic> map = json.decode(jsonMap);

    switch(EquipmentType.values[map['equipment_type']]){
      case EquipmentType.dispenser:
        return Dispenser(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], FactoryMaterialType.values[map['dispense_material']], dispenseAmount: map['dispense_amount'], dispenseTickDuration: map['tick_duration']);
      case EquipmentType.roller:
        return Roller(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], rollerTickDuration: map['tick_duration']);
      case EquipmentType.crafter:
        return Crafter(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], FactoryMaterialType.values[map['craft_material']], craftingTickDuration: map['tick_duration']);
      case EquipmentType.splitter:
        return Splitter(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], map['splitter_directions'].map<Direction>((dynamic direction) => Direction.values[direction]).toList());
      case EquipmentType.sorter:
        final Map<FactoryRecipeMaterialType, Direction> _sorterMap = <FactoryRecipeMaterialType, Direction>{};

        map['sorter_directions'].forEach((dynamic item){
          _sorterMap.addAll({
            FactoryRecipeMaterialType(FactoryMaterialType.values[item['material_type']], state: FactoryMaterialState.values[item['material_state']]): Direction.values[item['direction']]
          });
        });

        return Sorter(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], _sorterMap);
      case EquipmentType.seller:
        return Seller(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']]);
      case EquipmentType.hydraulic_press:
        return HydraulicPress(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], tickDuration: map['tick_duration'], pressCapacity: map['press_capacity']);
      case EquipmentType.wire_bender:
        return WireBender(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], tickDuration: map['tick_duration'], wireCapacity: map['wire_capacity']);
      case EquipmentType.cutter:
        return Cutter(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], tickDuration: map['tick_duration'], cutCapacity: map['cut_capacity']);
      case EquipmentType.melter:
        return Melter(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], tickDuration: map['tick_duration'], meltCapacity: map['melt_capacity']);
      case EquipmentType.freeRoller:
        return FreeRoller(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], tickDuration: map['tick_duration']);
    }

    return null;
  }
}

enum GameUpdate{
  tick, addEquipment, windowChange
}