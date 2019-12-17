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
import 'package:flutter_factory/game/model/unlockables_model.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/util/utils.dart';
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

  GameItems items;

  Future<void> _loadHive() async {
    final Directory _path = await getApplicationDocumentsDirectory();
    Hive.init(_path.path);

    if(!_didLoad){
      _didLoad = true;
      loadFactoryFloor();
    }

    items = GameItems();
  }

  Box hiveBox;

  int mapWidth = 31;
  int mapHeight = 31;

  List<FactoryEquipmentModel> get selectedEquipment => equipment.where((FactoryEquipmentModel fe) => selectedTiles.contains(fe.coordinates)).toList();
  bool get isSameEquipment => selectedEquipment.isEmpty || (selectedEquipment.every((FactoryEquipmentModel fe) => fe.type == selectedEquipment.first.type) && selectedEquipment.length == selectedTiles.length);
  bool get hasModify => selectedEquipment.first.type == EquipmentType.portal || selectedEquipment.first.type == EquipmentType.roller || selectedEquipment.first.type == EquipmentType.freeRoller || selectedEquipment.first.type == EquipmentType.wire_bender || selectedEquipment.first.type == EquipmentType.cutter || selectedEquipment.first.type == EquipmentType.hydraulic_press || selectedEquipment.first.type == EquipmentType.melter;

  List<T> getAll<T extends FactoryEquipmentModel>() => equipment.where((FactoryEquipmentModel fem) => fem is T).map<T>((FactoryEquipmentModel fem) => fem).toList();

  bool get isDraggable => (selectedEquipment.isEmpty && selectedTiles.isNotEmpty) || (selectedEquipment.isNotEmpty && hasModify);

  final GameCameraPosition gameCameraPosition = GameCameraPosition();
  int factoryFloor = 0;

  CopyMode copyMode = CopyMode.move;
  SelectMode selectMode = SelectMode.box;

  String get floor => getFloorName();

  String getFloorName(){
    if(factoryFloor == 0){
      return 'Ground floor';
    }else if(factoryFloor == 1){
      return 'First floor';
    }else if(factoryFloor == 2){
      return 'Second floor';
    }else if(factoryFloor == 3){
      return 'Secret floor';
    }else if(factoryFloor == 4){
      return 'Big floor';
    }else if(factoryFloor == 5){
      return 'Really big floor';
    }else{
      return 'Floor $factoryFloor';
    }
  }

  void changeFloor(int floor) async {
    if(floor == factoryFloor){
      return;
    }

    selectedTiles.clear();

    await saveFactory();

    await hiveBox.close();

    factoryFloor = floor;
    loadFactoryFloor();
  }

  void randomMainScreenFloor(int floor) async {
    if(floor == factoryFloor){
      return;
    }

    if(hiveBox == null){
      await _loadHive();
    }else{
      await hiveBox.close();
    }

    factoryFloor = floor;
    loadFactoryFloor();
  }

  Future<void> loadFactoryFloor() async {
    final int mapSize = factoryFloor < 4 ? 31 : factoryFloor == 4 ? 200 : 1000;

    mapHeight = mapSize;
    mapWidth = mapSize;

    print('Loading factory from DB!');

    hiveBox = await Hive.openBox<dynamic>('factory_floor_$factoryFloor');

    print(hiveBox.toMap());
    final Map<dynamic, dynamic> _result = hiveBox.toMap();

    if(_result.isEmpty){
      equipment.clear();
      return;
    }

    print('Got from DB!');

    final List<dynamic> _equipmentList = _result['equipment'];

    print('Loaded equipment: ${_equipmentList.length}');

    equipment.clear();
    equipment.addAll(_equipmentList.map((dynamic eq){
      final FactoryEquipmentModel _fem = equipmentFromMap(eq);
      final Map<String, dynamic> map = json.decode(eq);

      final List<dynamic> _materialMap = map['material'];
      final List<FactoryMaterialModel> _materials = _materialMap.map((dynamic map){
        final FactoryMaterialModel _material = materialFromMap(map);
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

  Future<void> saveFactory() async {
    if(!hiveBox.isOpen){
      hiveBox = await Hive.openBox<dynamic>('factory_floor_$factoryFloor');
    }

    await hiveBox.putAll(toMap());
    await hiveBox.compact();
  }

  Future<void> _autoSaveFactory() async {
    try{
      await hiveBox.putAll(toMap());
    } on HiveError {
      print('Autosave error!');
    }
  }

  Duration _duration = Duration();
  int _lastTrigger = -1;
  
  int _tickSpeed = 1200;
  bool showArrows = false;

  int currentCredit = 0;
  int lastTickEarnings = 0;

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
    tick();
    _duration += Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - _tickStart);
    _waitForTick();
  }

  void addEquipment(FactoryEquipmentModel eq){
    equipment.add(eq);
    _gameUpdate.add(GameUpdate.addEquipment);
  }

  void _findPortalPartner(UndergroundPortal up){
    final List<UndergroundPortal> _portals = equipment.where((FactoryEquipmentModel fmm) => fmm is UndergroundPortal).map<UndergroundPortal>((FactoryEquipmentModel fmm) => fmm).toList();

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

        equipment.add(fem);
      });

      addSelect.forEach((Coordinates c){
        if(!selectedTiles.contains(c)){
          selectedTiles.add(c);
        }
      });

      currentCredit -= selectedTiles.length * items.cost(e.type);
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

  String machineOperatingCost(EquipmentType type){
    switch(type){
      default: return '5';
    }
  }

  List<FactoryMaterialModel> get getExcessMaterial => _excessMaterial.fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _folded, List<FactoryMaterialModel> _m) => _folded..addAll(_m)).toList();
  List<FactoryMaterialModel> get getLastExcessMaterial => _excessMaterial.first;
  List<FactoryMaterialModel> get material => equipment.map((FactoryEquipmentModel fe) => fe.objects).fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _fm, List<FactoryMaterialModel> _em) => _fm..addAll(_em)).toList();

  void clearLine(){
    equipment.clear();

    _autoSaveFactory();
  }

  void removeEquipment(FactoryEquipmentModel eq){
    if(equipment.contains(eq)){
      equipment.remove(eq);
      currentCredit += items.cost(eq.type) ~/ 2;

      _autoSaveFactory();
    }
  }

  void loadLine(List<FactoryEquipmentModel> newLine){
    equipment.clear();
    equipment.addAll(newLine);

    _autoSaveFactory();
  }

  bool tick(){
    List<FactoryMaterialModel> _material;
    bool _realTick = false;

    if(!_isGameRunning){
      return false;
    }

    if(_duration.inMilliseconds ~/ _tickSpeed == _lastTrigger ~/ _tickSpeed){
      _material = equipment.fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _material, FactoryEquipmentModel e) => _material..addAll(e.objects));
    }else{
      _realTick = true;

      lastTickEarnings = equipment.fold<int>(0, (int value, FactoryEquipmentModel model){

        if(model.isActive){
          value -= model.operatingCost;
        }

        if(model is Seller){
          value += model.soldValue.round();
        }

        return value;
      });

      currentCredit += lastTickEarnings;

      _material = equipment.fold(<FactoryMaterialModel>[], (List<FactoryMaterialModel> _material, FactoryEquipmentModel e) => _material..addAll(e.equipmentTick()));
      _lastTrigger = _duration.inMilliseconds;

      if(_excessMaterial.length > _excessMaterialCleanup){
        _excessMaterial.removeAt(0);
      }

      equipment.forEach((FactoryEquipmentModel fem){
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

  final List<FactoryEquipmentModel> equipment = <FactoryEquipmentModel>[];
  final List<List<FactoryMaterialModel>> _excessMaterial = <List<FactoryMaterialModel>>[];

  final int _excessMaterialCleanup = 2;

  Stream<GameUpdate> get gameUpdate => _gameUpdate.stream;

  final PublishSubject<GameUpdate> _gameUpdate = PublishSubject<GameUpdate>();

  void dispose() async {
    _isGameRunning = false;
    _gameUpdate.close();

    await saveFactory();
    await hiveBox.close();
  }

  Map<dynamic, dynamic> toMap(){
    final List<String> _equipmentMap = equipment.map((FactoryEquipmentModel fe) => json.encode(fe.toMap())).toList();

    return <String, dynamic>{
      'factory_floor': factoryFloor,
      'equipment': _equipmentMap,
    };
  }
}

enum GameUpdate{
  tick, addEquipment, windowChange
}