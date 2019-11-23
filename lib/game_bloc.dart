import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' hide Radio;
import 'package:flutter/scheduler.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_color/random_color.dart';
import 'package:rxdart/rxdart.dart';
import 'package:hive/hive.dart';

import 'game/factory_material.dart';

enum GameMenuState{
  none, multipleSelected, multipleSameTypeSelected, singleSelected, inMutableSelected, emptySelected
}

enum CopyMode{
  move, copy
}

enum SelectMode{
  freestyle, box
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
    _loadHive();
  }

  bool _didLoad = false;

  Future<void> _loadHive() async {
    final Directory _path = await getApplicationDocumentsDirectory();
    Hive.init(_path.path);

    if(!_didLoad){
      _didLoad = true;
      _loadFactoryFloor();
    }
  }

  Box _hiveBox;

  int mapWidth = 31;
  int mapHeight = 31;

  List<FactoryEquipmentModel> get _selectedEquipment => equipment.where((FactoryEquipmentModel fe) => selectedTiles.contains(fe.coordinates)).toList();
  bool get isSameEquipment => _selectedEquipment.every((FactoryEquipmentModel fe) => fe.type == _selectedEquipment.first.type) && _selectedEquipment.length == selectedTiles.length;
  bool get hasModify => _selectedEquipment.first.type == EquipmentType.portal || _selectedEquipment.first.type == EquipmentType.roller || _selectedEquipment.first.type == EquipmentType.freeRoller || _selectedEquipment.first.type == EquipmentType.wire_bender || _selectedEquipment.first.type == EquipmentType.cutter || _selectedEquipment.first.type == EquipmentType.hydraulic_press || _selectedEquipment.first.type == EquipmentType.melter;

  List<T> getAll<T extends FactoryEquipmentModel>() => _equipment.where((FactoryEquipmentModel fem) => fem is T).map<T>((FactoryEquipmentModel fem) => fem).toList();

  bool get isDraggable => (_selectedEquipment.isEmpty && selectedTiles.isNotEmpty) || (_selectedEquipment.isNotEmpty && hasModify);

  final GameCameraPosition gameCameraPosition = GameCameraPosition();
  int _factoryFloor = 0;

  CopyMode copyMode = CopyMode.move;
  SelectMode selectMode = SelectMode.box;

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
    }else if(_factoryFloor == 4){
      return 'Big floor';
    }else if(_factoryFloor == 5){
      return 'Really big floor';
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

  void randomMainScreenFloor(int factoryFloor) async {
    if(factoryFloor == _factoryFloor){
      return;
    }

    if(_hiveBox == null){
      await _loadHive();
    }else{
      await _hiveBox.close();
    }

    _factoryFloor = factoryFloor;
    _loadFactoryFloor();
  }

  Future<void> _loadFactoryFloor() async {
    final int mapSize = _factoryFloor < 4 ? 31 : _factoryFloor == 4 ? 200 : 1000;

    mapHeight = mapSize;
    mapWidth = mapSize;

    print('Loading factory from DB!');

    _hiveBox = await Hive.openBox<dynamic>('factory_floor_$_factoryFloor');

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

    final List<UndergroundPortal> _portals = getAll<UndergroundPortal>();

    _portals.forEach((UndergroundPortal up){
      final UndergroundPortal _connectingPortal = _portals.firstWhere((UndergroundPortal _up) => _up.coordinates == up.connectingPortal, orElse: () => null);

      if(_connectingPortal != null){
        _connectingPortal.connectingPortal = up.coordinates;
        up.connectingPortal = _connectingPortal.coordinates;

        final Color _lineColor = RandomColor().randomColor();

        _connectingPortal.lineColor = _lineColor;
        up.lineColor = _lineColor;
      }
    });

    print(_result);
  }

  Future<void> _saveFactory() async {
    await _hiveBox.putAll(toMap());
    await _hiveBox.compact();
  }

  Future<void> _autoSaveFactory() async {
    try{
      await _hiveBox.putAll(toMap());
    } on HiveError {
      print('Autosave error!');
    }
  }

  Duration _duration = Duration();
  int _lastTrigger = -1;
  
  int _tickSpeed = 1200;
  bool showArrows = false;

  EquipmentType buildSelectedEquipmentType = EquipmentType.roller;
  Direction buildSelectedEquipmentDirection = Direction.south;

  List<Coordinates> selectedTiles = <Coordinates>[];

  void increaseGameSpeed() => _tickSpeed = (_tickSpeed * 0.5).round();
  void decreaseGameSpeed() => _tickSpeed *= 2;

  void changeTickSpeed(int newSpeed) => _tickSpeed = newSpeed;

  int get gameSpeed => _tickSpeed;

  int _frameRate = 0;
  int _tickStart = 0;

  bool _isGameRunning = true;

  List<int> _averageFrameRate = <int>[];

  int get frameRate => _averageFrameRate.fold(0, (int _rate, int _value) => _rate += _value) ~/ _averageFrameRate.length;

  double get progress => _duration.inMilliseconds ~/ _tickSpeed == _lastTrigger ~/ _tickSpeed ? (_duration.inMilliseconds / _tickSpeed) % 1 : 1.0;

  void _waitForTick() async {
    if(!_isGameRunning){
      return;
    }

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

  void _findPortalPartner(UndergroundPortal up){
    final List<UndergroundPortal> _portals = _equipment.where((FactoryEquipmentModel fmm) => fmm is UndergroundPortal).map<UndergroundPortal>((FactoryEquipmentModel fmm) => fmm).toList();

    if(up.connectingPortal != null){
      final UndergroundPortal _portal = _portals.firstWhere((UndergroundPortal _up) => _up.coordinates == up.connectingPortal, orElse: () => null);

      if(_portal != null && (_portal.coordinates.x == up.coordinates.x || _portal.coordinates.y == up.coordinates.y)){

        if(_portal.coordinates.x == up.coordinates.x){
          if(_portal.coordinates.y < up.coordinates.y){
            _portal.direction = Direction.south;
            up.direction = Direction.north;
          }else{
            _portal.direction = Direction.north;
            up.direction = Direction.south;
          }
        }else{
          if(_portal.coordinates.x < up.coordinates.x){
            _portal.direction = Direction.west;
            up.direction = Direction.east;
          }else{
            _portal.direction = Direction.east;
            up.direction = Direction.west;
          }
        }
        return;
      }

      print('Portal ${up.coordinates.toMap()} lost it\'s partner!');
      up.connectingPortal = null;
    }

    print('Building portal!');
    final List<UndergroundPortal> _connectingPortal = _portals.where((UndergroundPortal fem){
      if(fem.coordinates == up.coordinates){
        return false;
      }

      bool _hasPartner = false;

      for(int i = 0; i < 32; i++){
        _hasPartner = _hasPartner || (fem.coordinates.y == up.coordinates.y - i && fem.coordinates.x == up.coordinates.x);
        _hasPartner = _hasPartner || (fem.coordinates.y == up.coordinates.y + i && fem.coordinates.x == up.coordinates.x);
        _hasPartner = _hasPartner || fem.coordinates.x == up.coordinates.x - i && fem.coordinates.y == up.coordinates.y;
        _hasPartner = _hasPartner || fem.coordinates.x == up.coordinates.x + i && fem.coordinates.y == up.coordinates.y;
      }

      return _hasPartner;
    }).toList();

    if(_connectingPortal == null || _connectingPortal.isEmpty){
      print('No connecting portal!');
      return;
    }

    _connectingPortal.firstWhere((UndergroundPortal fem){
      if(fem.coordinates == up.coordinates){
        return false;
      }

      final UndergroundPortal _portal = _portals.firstWhere((UndergroundPortal _up) => _up.coordinates == fem.connectingPortal, orElse: () => null);

      if(_portal != null && (_portal.coordinates.x == fem.coordinates.x || _portal.coordinates.y == fem.coordinates.y)){
        print('Candidate is already connected! ${_portal.coordinates.toMap()} - ${fem.coordinates.toMap()}');
        return false;
      }

      print('Connecting portal is: ${fem.coordinates.toMap()}');
      print('Connection length: ${up.toMap()} - ${fem.coordinates.toMap()}');
      print('Connection length: ${up.coordinates.x - fem.coordinates.x}');

      fem.connectingPortal = up.coordinates;
      up.connectingPortal = fem.coordinates;

      final Color _lineColor = RandomColor().randomColor();

      fem.lineColor = _lineColor;
      up.lineColor = _lineColor;

      print('Portal ${up.coordinates.toMap()} FOUND it\'s partner!');

      if(fem.coordinates.x == up.coordinates.x){
        if(fem.coordinates.y < up.coordinates.y){
          fem.direction = Direction.south;
          up.direction = Direction.north;
        }else{
          fem.direction = Direction.north;
          up.direction = Direction.south;
        }
      }else{
        if(fem.coordinates.x < up.coordinates.x){
          fem.direction = Direction.west;
          up.direction = Direction.east;
        }else{
          fem.direction = Direction.east;
          up.direction = Direction.west;
        }
      }
      return true;
    }, orElse: (){
      print('Passed all candidates ${_connectingPortal.length} but no connecting portal was found!');
      return null;
    });
  }

  void buildSelected(){
    void _addEquipment(FactoryEquipmentModel e){
      print('Building equipment! ${e.type}');
      List<Coordinates> addSelect = <Coordinates>[];

      selectedTiles.forEach((Coordinates c){
        FactoryEquipmentModel fem = e.copyWith(coordinates: c);

        if(e.type == EquipmentType.portal){
          _findPortalPartner(fem);

          if(fem is UndergroundPortal && fem.connectingPortal != null && !addSelect.contains(fem.connectingPortal)){
            addSelect.add(fem.connectingPortal);
          }
        }

        _equipment.add(fem);
      });

      addSelect.forEach((Coordinates c){
        if(!selectedTiles.contains(c)){
          selectedTiles.add(c);
        }
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
      case EquipmentType.rotatingFreeRoller:
        _addEquipment(RotatingFreeRoller(Coordinates(0, 0), buildSelectedEquipmentDirection));
        break;
      case EquipmentType.portal:
        _addEquipment(UndergroundPortal(Coordinates(0, 0), buildSelectedEquipmentDirection));
        break;
    }

    _autoSaveFactory();
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
      case EquipmentType.rotatingFreeRoller:
        return RotatingFreeRoller(selectedTiles.first, buildSelectedEquipmentDirection);
      case EquipmentType.portal:
        return UndergroundPortal(selectedTiles.first, buildSelectedEquipmentDirection);
    }

    return null;
  }

  List<FactoryMaterialModel> get getExcessMaterial => _excessMaterial.fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _folded, List<FactoryMaterialModel> _m) => _folded..addAll(_m)).toList();
  List<FactoryMaterialModel> get getLastExcessMaterial => _excessMaterial.first;
  List<FactoryEquipmentModel> get equipment => _equipment;
  List<FactoryMaterialModel> get material => _equipment.map((FactoryEquipmentModel fe) => fe.objects).fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _fm, List<FactoryMaterialModel> _em) => _fm..addAll(_em)).toList();

  void clearLine(){
    _equipment.clear();

    _autoSaveFactory();
  }

  void removeEquipment(FactoryEquipmentModel equipment){
    if(_equipment.contains(equipment)){
      _equipment.remove(equipment);

      _autoSaveFactory();
    }
  }

  void loadLine(List<FactoryEquipmentModel> newLine){
    _equipment.clear();
    _equipment.addAll(newLine);

    _autoSaveFactory();
  }

  bool _tick(){
    List<FactoryMaterialModel> _material;
    bool _realTick = false;

    if(!_isGameRunning){
      return false;
    }

    if(_duration.inMilliseconds ~/ _tickSpeed == _lastTrigger ~/ _tickSpeed){
      _material = _equipment.fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _material, FactoryEquipmentModel e) => _material..addAll(e.objects));
    }else{
      _realTick = true;
      _material = _equipment.fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _material, FactoryEquipmentModel e) => _material..addAll(e.equipmentTick()));
      _lastTrigger = _duration.inMilliseconds;

      if(_excessMaterial.length > _excessMaterialCleanup){
        _excessMaterial.removeAt(0);
      }

      _equipment.forEach((FactoryEquipmentModel fem){
        _material.removeWhere((FactoryMaterialModel fmm){
          bool _remove = false;

          if(fmm.x == fem.coordinates.x && fmm.y == fem.coordinates.y){
            _remove = true;
            fem.input(fmm);
          }

          return _remove;
        });
      });

      _excessMaterial.add(_material);
    }

    _gameUpdate.add(GameUpdate.tick);

    return _realTick;
  }

  final List<FactoryEquipmentModel> _equipment = <FactoryEquipmentModel>[];
  final List<List<FactoryMaterialModel>> _excessMaterial = <List<FactoryMaterialModel>>[];

  final int _excessMaterialCleanup = 2;

  Stream<GameUpdate> get gameUpdate => _gameUpdate.stream;

  final PublishSubject<GameUpdate> _gameUpdate = PublishSubject<GameUpdate>();

  void dispose() async {
    _isGameRunning = false;
    _gameUpdate.close();

    await _saveFactory();
    await _hiveBox.close();
  }

  Map<dynamic, dynamic> toMap(){
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
        return Dispenser(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], FactoryMaterialType.values[map['dispense_material']], dispenseAmount: map['dispense_amount'], dispenseTickDuration: map['tick_duration'], isMutable: map['is_mutable'], isWorking: map['is_working'] ?? true);
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
      case EquipmentType.rotatingFreeRoller:
        return RotatingFreeRoller(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], tickDuration: map['tick_duration']);
      case EquipmentType.portal:
        Coordinates _portal;

        if(map['connecting_portal'] != null){
          _portal = Coordinates(map['connecting_portal']['x'], map['connecting_portal']['y']);
        }

        return UndergroundPortal(Coordinates(map['position']['x'], map['position']['y']), Direction.values[map['direction']], connectingPortal: _portal);
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
      case FactoryMaterialType.headphones:
        return Headphones.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.powerSupply:
        return PowerSupply.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.speakers:
        return Speakers.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.radio:
        return Radio.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.tv:
        return Tv.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.tablet:
        return Tablet.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.microwave:
        return Microwave.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.fridge:
        return Fridge.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.smartphone:
        return Smartphone.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.computer:
        return Computer.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.electricBoard:
        return ElectricBoard.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.generator:
        return Generator.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.smartWatch:
        return SmartWatch.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.waterHeater:
        return WaterHeater.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.advancedEngine:
        return AdvancedEngine.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.electricEngine:
        return ElectricEngine.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.laser:
        return Laser.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.oven:
        return Oven.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.superComputer:
        return SuperComputer.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.robot:
        return AiRobot.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.robotHead:
        return AiRobotHead.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.robotBody:
        return AiRobotBody.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.aiProcessor:
        return AiProcessor.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.drill:
        return Drill.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.jackHammer:
        return JackHammer.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
      case FactoryMaterialType.electricGenerator:
        return ElectricGenerator.fromOffset(Offset(map['position']['x'], map['position']['y']))..direction = (map['direction'] != null ? Direction.values[map['direction']] : null);
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
    final bool _realTick = super._tick();

    if(_realTick && challengeGoal != null){
      int soldItems = 0;

      if(goalSeller != null){
        goalSeller.soldItems.getRange(max(goalSeller.soldItems.length - 60, 0), goalSeller.soldItems.length).forEach((List<FactoryRecipeMaterialType> frmtList){
          soldItems += frmtList.where((FactoryRecipeMaterialType frmt) => frmt.materialType == challengeGoal.keys.first.materialType).length;
        });
      }

      if(!_didComplete){
        complete = (soldItems / 60) / challengeGoal.values.first;
        _didComplete = complete == 1.0;
      }else{
        complete = 1.0;
      }

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

    _hiveBox = await Hive.openBox<dynamic>('challenge_$_factoryFloor');
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