import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:hive/hive.dart';

import 'game/factory_material.dart';

enum GameWindows{
  buy, settings
}

class GameCameraPosition{
  double scale = 1.0;
  Offset position = Offset.zero;

  void reset(){
    scale = 1.0;
    position = Offset.zero;
  }
}

class GameBloc{
  GameBloc(){
    _waitForTick();

    _loadHive().then((_){
      _loadFactoryFloor();
    });
  }

  Future<void> _loadHive() async {
    final Directory _path = await getApplicationDocumentsDirectory();
    Hive.init(_path.path);
  }

  Box _hiveBox;

  int mapWidth = 31;
  int mapHeight = 31;

  final GameCameraPosition gameCameraPosition = GameCameraPosition();
  int _factoryFloor = 0;

  String get floor => _getFloorName();

  String _getFloorName(){
    if(_factoryFloor == 0){
      return 'Ground floor';
    }else if(_factoryFloor == 1){
      return 'First floor';
    }else if(_factoryFloor == 2){
      return 'Second floor';
    }else if(_factoryFloor == 3){
      return 'Secret floor';
    }else{
      return 'Floor $_factoryFloor';
    }
  }

  void changeFloor(int factoryFloor) async {
    if(factoryFloor == _factoryFloor){
      return;
    }

    selectedTiles.clear();

    await _saveFactory();

    await _hiveBox.close();
    _factoryFloor = factoryFloor;
    _loadFactoryFloor();
  }

  Future<void> _loadFactoryFloor() async {
    mapHeight = 31;
    mapWidth = 31;

    print('Loading factory from DB!');

    _hiveBox = await Hive.openBox('factory_floor_$_factoryFloor');

    print(_hiveBox.toMap());
    final Map<dynamic, dynamic> _result = _hiveBox.toMap();

    if(_result.isEmpty){
      _equipment.clear();
      return;
    }

    print('Got from DB!');

    final List<dynamic> _equipmentList = _result['equipment'];

    print('Loaded equipment: ${_equipmentList.length}');

    _equipment.clear();
    _equipment.addAll(_equipmentList.map((dynamic eq){
      final FactoryEquipmentModel _fem = _equipmentFromMap(eq);
//      _fem.objects.add(Gold.fromOffset(Offset(_fem.coordinates.x.toDouble(), _fem.coordinates.y.toDouble())));

      final Map<String, dynamic> map = json.decode(eq);

      final List<dynamic> _materialMap = map['material'];
      final List<FactoryMaterialModel> _materials = _materialMap.map((dynamic map){
        final FactoryMaterialModel _material = _materialFromMap(map);
        _material.direction ??= _fem.direction;
        return _material;
      }).toList();

      _fem.objects.addAll(_materials);

      return _fem;
    }));

    print(_result);
  }

  Future<void> _saveFactory() async {
    await _hiveBox.putAll(toMap());
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

  void changeTickSpeed(int newSpeed) => _tickSpeed = newSpeed;

  int get gameSpeed => _tickSpeed;

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

  void addEquipment(FactoryEquipmentModel equipment){
    _equipment.add(equipment);
    _gameUpdate.add(GameUpdate.addEquipment);
  }

  void buildSelected(){
    void _addEquipment(FactoryEquipmentModel e){
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

  FactoryEquipmentModel previewEquipment(EquipmentType type){
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

  List<FactoryMaterialModel> get getExcessMaterial => _excessMaterial.fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _folded, List<FactoryMaterialModel> _m) => _folded..addAll(_m)).toList();
  List<FactoryMaterialModel> get getLastExcessMaterial => _excessMaterial.first;
  List<FactoryEquipmentModel> get equipment => _equipment;
  List<FactoryMaterialModel> get material => _equipment.map((FactoryEquipmentModel fe) => fe.objects).fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _fm, List<FactoryMaterialModel> _em) => _fm..addAll(_em)).toList();

  void clearLine(){
    _equipment.clear();

    _saveFactory();
  }

  void removeEquipment(FactoryEquipmentModel equipment){
    if(_equipment.contains(equipment)){
      _equipment.remove(equipment);

      _saveFactory();
    }
  }

  void loadLine(List<FactoryEquipmentModel> newLine){
    _equipment.clear();
    _equipment.addAll(newLine);

    _saveFactory();
  }

  bool _tick(){
    List<FactoryMaterialModel> _material;
    bool _realTick = false;

    if(_duration.inMilliseconds ~/ _tickSpeed == _lastTrigger ~/ _tickSpeed){
      _material = _equipment.fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _material, FactoryEquipmentModel e) => _material..addAll(e.objects));
    }else{
      _realTick = true;
      _material = _equipment.fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _material, FactoryEquipmentModel e) => _material..addAll(e.equipmentTick()));
      _lastTrigger = _duration.inMilliseconds;

      if(_excessMaterial.length > _excessMaterialCleanup){
        _excessMaterial.removeAt(0);
      }

      final List<FactoryMaterialModel> _excess = <FactoryMaterialModel>[];

      _material.forEach((FactoryMaterialModel fm){
        FactoryEquipmentModel _e = _equipment.firstWhere((FactoryEquipmentModel fe) => fe.coordinates.x == fm.x.floor() && fe.coordinates.y == fm.y.floor(), orElse: () => null);
        if(_e != null){
          _e.input(fm);
        }else{
          _excess.add(fm);
        }
      });

      _excessMaterial.add(_excess);
    }

    _gameUpdate.add(GameUpdate.tick);

    return _realTick;
  }

  void changeWindow(GameWindows window){
    currentWindow = window;
    _gameUpdate.add(GameUpdate.windowChange);
  }

  final List<FactoryEquipmentModel> _equipment = <FactoryEquipmentModel>[];
  final List<List<FactoryMaterialModel>> _excessMaterial = <List<FactoryMaterialModel>>[];

  final int _excessMaterialCleanup = 2;

  Stream<GameUpdate> get gameUpdate => _gameUpdate.stream;

  final PublishSubject<GameUpdate> _gameUpdate = PublishSubject<GameUpdate>();

  void dispose(){
    _saveFactory();
    _hiveBox.close();
    _gameUpdate.close();
  }

  Map<String, dynamic> toMap(){
    final List<String> _equipmentMap = equipment.map((FactoryEquipmentModel fe) => json.encode(fe.toMap())).toList();

    return <String, dynamic>{
      'factory_floor': _factoryFloor,
      'equipment': _equipmentMap,
    };
  }


  FactoryEquipmentModel _equipmentFromMap(String jsonMap){
    final Map<String, dynamic> map = json.decode(jsonMap);

    switch(EquipmentType.values[map['equipment_type']]){
      case EquipmentType.dispenser:
        return Dispenser(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], FactoryMaterialType.values[map['dispense_material']], dispenseAmount: map['dispense_amount'], dispenseTickDuration: map['tick_duration'], isMutable: map['is_mutable']);
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
        return Seller(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], isMutable: map['is_mutable']);
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

  FactoryMaterialModel _materialFromMap(Map<String, dynamic> map){
//    final Map<String, dynamic> map = json.decode(jsonMap);

    switch(FactoryMaterialType.values[map['material_type']]){
      case FactoryMaterialType.iron:
        return Iron.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.copper:
        return Copper.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.diamond:
        return Diamond.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.gold:
        return Gold.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.aluminium:
        return Aluminium.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.computerChip:
        return ComputerChip.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.processor:
        return Processor.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.engine:
        return Engine.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.heaterPlate:
        return HeaterPlate.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.coolerPlate:
        return CoolerPlate.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.lightBulb:
        return LightBulb.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.clock:
        return Clock.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.railway:
        return Railway.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.battery:
        return Battery.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.drone:
        return Drone.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.antenna:
        return Antenna.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.grill:
        return Grill.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.airCondition:
        return AirConditioner.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.washingMachine:
        return WashingMachine.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.toaster:
        return Toaster.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.solarPanel:
        return SolarPanel.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.serverRack:
        return ServerRack.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
    }

    return null;
  }
}

class ChallengesBloc extends GameBloc{
  ChallengesBloc(int challenge) : super() {
    _challenge = challenge;

    _loadFactoryFloor();
  }

  int _challenge = 0;
  
  bool _didComplete = false;

  double complete = 0.0;

  Map<FactoryRecipeMaterialType, double> challengeGoal;
  
  Seller goalSeller;

  @override
  int get _factoryFloor => _challenge;

  void loadChallenge(int challenge) => changeFloor(challenge);
  
  @override
  bool _tick(){
    bool _realTick = super._tick();

    if(_realTick && challengeGoal != null){
      int soldItems = 0;

      if(goalSeller != null){
        goalSeller.soldItems.getRange(max(goalSeller.soldItems.length - 60, 0), goalSeller.soldItems.length).forEach((List<FactoryRecipeMaterialType> frmtList){
          soldItems += frmtList.where((FactoryRecipeMaterialType frmt) => frmt.materialType == challengeGoal.keys.first.materialType).length;
        });
      }

      complete = (soldItems / 60) / challengeGoal.values.first;
      _didComplete = complete == 1.0;

      print('Sold items: $soldItems / $_didComplete / $complete');
    }

    return _realTick;
  }

  String getChallengeGoalDescription(){
    if(challengeGoal == null || challengeGoal.isEmpty){
      return '';
    }

    final FactoryRecipeMaterialType _frmt = challengeGoal.keys.first;
    return 'You have to produce ${challengeGoal[_frmt]} ${factoryMaterialToString(_frmt.materialType)} per tick';
  }

  @override
  String _getFloorName(){
    return 'Challenge ${_challenge + 1}';
  }

  @override
  void changeFloor(int factoryFloor){}

  @override
  Future<void> _saveFactory() async {
    _hiveBox.putAll(toMap());
  }

  @override
  Future<void> _loadFactoryFloor() async {
    if(_challenge == 0){
      _loadFirstChallenge();
    }else if(_challenge == 1){
      _loadSecondChallenge();
    }else if(_challenge == 2){
      _loadThirdChallenge();
    }else if(_challenge == 3){
      _loadFourthChallenge();
    }else{
      _loadFifthChallenge();
    }

    print('Loading factory from DB!');

    _hiveBox = await Hive.openBox('challenge_$_factoryFloor');
    final Map<dynamic, dynamic> _result = _hiveBox.toMap();

    if(_result == null || _result.isEmpty){
      goalSeller = _equipment.firstWhere((FactoryEquipmentModel fem) => fem is Seller);
      return;
    }

    print('Got from DB!');

    _didComplete = _result['did_complete'];
    final List<dynamic> _equipmentList = _result['equipment'];

    print('Loaded equipment: ${_equipmentList.length}');

    _equipment.clear();
    _equipment.addAll(_equipmentList.map((dynamic eq){
      final FactoryEquipmentModel _fem = _equipmentFromMap(eq);
      //      _fem.objects.add(Gold.fromOffset(Offset(_fem.coordinates.x.toDouble(), _fem.coordinates.y.toDouble())));

      final Map<String, dynamic> map = json.decode(eq);

      final List<dynamic> _materialMap = map['material'];
      final List<FactoryMaterialModel> _materials = _materialMap.map((dynamic map){
        final FactoryMaterialModel _material = _materialFromMap(map);
        _material.direction ??= _fem.direction;
        return _material;
      }).toList();

      _fem.objects.addAll(_materials);

      return _fem;
    }));

    print(_result);
    goalSeller = _equipment.firstWhere((FactoryEquipmentModel fem) => fem is Seller);
  }

  void _loadFirstChallenge(){
    challengeGoal = <FactoryRecipeMaterialType, double>{
      FactoryRecipeMaterialType(FactoryMaterialType.washingMachine): 2
    };

    gameCameraPosition.position = Offset(60.0, 300.0);
    gameCameraPosition.scale = 2.0;

    mapWidth = 5;
    mapHeight = 4;

    _equipment.clear();

    _equipment.add(Dispenser(
      Coordinates(0, 0),
      Direction.north,
      FactoryMaterialType.iron,
      dispenseAmount: 4,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(5, 0),
      Direction.north,
      FactoryMaterialType.gold,
      dispenseAmount: 2,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(5, 4),
      Direction.south,
      FactoryMaterialType.copper,
      dispenseAmount: 4,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(0, 4),
      Direction.south,
      FactoryMaterialType.aluminium,
      dispenseAmount: 4,
      isMutable: false
    ));

    _equipment.add(Seller(
      Coordinates(4, 4),
      Direction.south,
      isMutable: false
    ));
  }

  void restart() async {
    await _hiveBox.clear();
    _loadFactoryFloor();
  }

  void _loadSecondChallenge(){
    challengeGoal = <FactoryRecipeMaterialType, double>{
      FactoryRecipeMaterialType(FactoryMaterialType.airCondition): 1
    };

    gameCameraPosition.position = Offset(90.0, 300.0);
    gameCameraPosition.scale = 2.0;

    mapWidth = 4;
    mapHeight = 4;

    _equipment.clear();

    _equipment.add(Dispenser(
      Coordinates(0, 0),
      Direction.north,
      FactoryMaterialType.diamond,
      dispenseAmount: 1,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(1, 1),
      Direction.north,
      FactoryMaterialType.gold,
      dispenseAmount: 1,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(2, 2),
      Direction.west,
      FactoryMaterialType.gold,
      dispenseAmount: 1,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(3, 3),
      Direction.north,
      FactoryMaterialType.gold,
      dispenseAmount: 1,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(4, 4),
      Direction.west,
      FactoryMaterialType.aluminium,
      dispenseAmount: 1,
      isMutable: false
    ));

    _equipment.add(Seller(
      Coordinates(0, 4),
      Direction.west,
      isMutable: false
    ));
  }

  void _loadThirdChallenge(){
    challengeGoal = <FactoryRecipeMaterialType, double>{
      FactoryRecipeMaterialType(FactoryMaterialType.lightBulb): 1
    };

    gameCameraPosition.position = Offset(120.0, 300.0);
    gameCameraPosition.scale = 2.5;

    mapWidth = 2;
    mapHeight = 3;

    _equipment.clear();

    _equipment.add(Dispenser(
      Coordinates(0, 0),
      Direction.east,
      FactoryMaterialType.copper,
      dispenseAmount: 2,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(0, 3),
      Direction.east,
      FactoryMaterialType.iron,
      dispenseAmount: 2,
      isMutable: false
    ));

    _equipment.add(Seller(
      Coordinates(2, 0),
      Direction.west,
      isMutable: false
    ));
  }

  void _loadFourthChallenge(){
    challengeGoal = <FactoryRecipeMaterialType, double>{
      FactoryRecipeMaterialType(FactoryMaterialType.engine): 1
    };

    gameCameraPosition.position = Offset(120.0, 300.0);
    gameCameraPosition.scale = 2.5;

    mapWidth = 2;
    mapHeight = 3;

    _equipment.clear();

    _equipment.add(Dispenser(
      Coordinates(0, 0),
      Direction.east,
      FactoryMaterialType.gold,
      dispenseAmount: 1,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(0, 3),
      Direction.east,
      FactoryMaterialType.iron,
      dispenseAmount: 2,
      isMutable: false
    ));

    _equipment.add(Seller(
      Coordinates(2, 0),
      Direction.west,
      isMutable: false
    ));
  }

  void _loadFifthChallenge(){
    challengeGoal = <FactoryRecipeMaterialType, double>{
      FactoryRecipeMaterialType(FactoryMaterialType.railway): 0.6
    };

    gameCameraPosition.position = Offset(80.0, 300.0);
    gameCameraPosition.scale = 2.0;

    mapWidth = 4;
    mapHeight = 4;

    _equipment.clear();

    _equipment.add(Dispenser(
      Coordinates(0, 0),
      Direction.north,
      FactoryMaterialType.iron,
      dispenseAmount: 4,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(2, 0),
      Direction.north,
      FactoryMaterialType.iron,
      dispenseAmount: 4,
      isMutable: false
    ));

    _equipment.add(Dispenser(
      Coordinates(4, 0),
      Direction.north,
      FactoryMaterialType.iron,
      dispenseAmount: 4,
      isMutable: false
    ));

    _equipment.add(Seller(
      Coordinates(2, 4),
      Direction.north,
      isMutable: false
    ));
  }
  
  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    
    _map.addAll(<String, dynamic>{
      'did_complete': _didComplete
    });
    
    return _map;
  }
}

enum GameUpdate{
  tick, addEquipment, windowChange
}