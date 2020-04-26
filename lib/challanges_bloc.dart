import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/game/money_manager/sandbox_manager.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/util/utils.dart';
import 'package:hive/hive.dart';
import 'package:random_color/random_color.dart';

import 'game/model/coordinates.dart';
import 'game/model/factory_equipment_model.dart';

class ChallengesBloc extends GameBloc {
  ChallengesBloc(int challenge) : super(moneyManager: SandboxManager()) {
    factoryFloor = challenge;

    loadFactoryFloor();
  }

  bool _didComplete = false;

  double complete = 0.0;

  Map<FactoryRecipeMaterialType, double> challengeGoal;

  Seller goalSeller;

  void loadChallenge(int challenge) => changeFloor(challenge);

  @override
  bool tick() {
    final bool _realTick = super.tick();

    if (_realTick && challengeGoal != null) {
      int soldItems = 0;

      if (goalSeller != null) {
        goalSeller.soldItems
            .getRange(max(goalSeller.soldItems.length - 60, 0), goalSeller.soldItems.length)
            .forEach((List<FactoryRecipeMaterialType> frmtList) {
          soldItems += frmtList
              .where((FactoryRecipeMaterialType frmt) => frmt.materialType == challengeGoal.keys.first.materialType)
              .length;
        });
      }

      if (!_didComplete) {
        complete = (soldItems / 60) / challengeGoal.values.first;
        _didComplete = complete == 1.0;
      } else {
        complete = 1.0;
      }

      print('Sold items: $soldItems / $_didComplete / $complete');
    }

    return _realTick;
  }

  String getChallengeGoalDescription() {
    if (challengeGoal == null || challengeGoal.isEmpty) {
      return '';
    }

    final FactoryRecipeMaterialType _frmt = challengeGoal.keys.first;
    return 'You have to produce ${challengeGoal[_frmt]} ${factoryMaterialToString(_frmt.materialType)} per tick';
  }

  @override
  String getFloorName({int floor}) {
    return 'Challenge ${(floor ?? factoryFloor) + 1}';
  }

  @override
  void changeFloor(int factoryFloor) {}

  @override
  Future<void> saveFactory() async {
    if (!hiveBox.isOpen) {
      hiveBox = await Hive.openBox<dynamic>('challenge_$factoryFloor');
    }

    await hiveBox.putAll(toMap());
    await hiveBox.compact();
  }

  @override
  Future<void> loadFactoryFloor() async {
    if (factoryFloor == 0) {
      _loadFirstChallenge();
    } else if (factoryFloor == 1) {
      _loadSecondChallenge();
    } else if (factoryFloor == 2) {
      _loadThirdChallenge();
    } else if (factoryFloor == 3) {
      _loadFourthChallenge();
    } else {
      _loadFifthChallenge();
    }

    print('Loading factory from DB!');

    hiveBox = await Hive.openBox<dynamic>('challenge_$factoryFloor');
    final Map<dynamic, dynamic> _result = hiveBox.toMap();

    if (_result == null || _result.isEmpty) {
      goalSeller = equipment.firstWhere((FactoryEquipmentModel fem) => fem is Seller);
      return;
    }

    print('Got from DB!');

    _didComplete = _result['did_complete'];
    final List<dynamic> equipmentList = _result['equipment'];

    print('Loaded equipment: ${equipmentList.length}');

    equipment.clear();
    equipment.addAll(equipmentList.map((dynamic eq) {
      final FactoryEquipmentModel _fem = equipmentFromMap(eq);
      //      _fem.objects.add(Gold.fromOffset(Offset(_fem.coordinates.x.toDouble(), _fem.coordinates.y.toDouble())));

      final Map<String, dynamic> map = json.decode(eq);

      final List<dynamic> _materialMap = map['material'];
      final List<FactoryMaterialModel> _materials = _materialMap.map((dynamic map) {
        final FactoryMaterialModel _material = materialFromMap(map);
        _material.direction ??= _fem.direction;
        return _material;
      }).toList();

      _fem.objects.addAll(_materials);

      return _fem;
    }));

    final List<UndergroundPortal> _portals = getAll<UndergroundPortal>();

    _portals.forEach((UndergroundPortal up) {
      final UndergroundPortal _connectingPortal =
          _portals.firstWhere((UndergroundPortal _up) => _up.coordinates == up.connectingPortal, orElse: () => null);

      if (_connectingPortal != null) {
        _connectingPortal.connectingPortal = up.coordinates;
        up.connectingPortal = _connectingPortal.coordinates;

        final Color _lineColor = RandomColor().randomColor();

        _connectingPortal.lineColor = _lineColor;
        up.lineColor = _lineColor;
      }
    });

    print(_result);
    goalSeller = equipment.firstWhere((FactoryEquipmentModel fem) => fem is Seller);
  }

  void _loadFirstChallenge() {
    challengeGoal = <FactoryRecipeMaterialType, double>{
      FactoryRecipeMaterialType(FactoryMaterialType.washingMachine): 2
    };

    gameCameraPosition.position = Offset(60.0, 300.0);
    gameCameraPosition.scale = 2.0;

    mapWidth = 5;
    mapHeight = 4;

    equipment.clear();

    equipment.add(
        Dispenser(Coordinates(0, 0), Direction.north, FactoryMaterialType.iron, dispenseAmount: 4, isMutable: false));

    equipment.add(
        Dispenser(Coordinates(5, 0), Direction.north, FactoryMaterialType.gold, dispenseAmount: 2, isMutable: false));

    equipment.add(
        Dispenser(Coordinates(5, 4), Direction.south, FactoryMaterialType.copper, dispenseAmount: 4, isMutable: false));

    equipment.add(Dispenser(Coordinates(0, 4), Direction.south, FactoryMaterialType.aluminium,
        dispenseAmount: 4, isMutable: false));

    equipment.add(Seller(Coordinates(4, 4), Direction.south, isMutable: false));
  }

  void restart() async {
    await hiveBox.clear();
    loadFactoryFloor();
  }

  void _loadSecondChallenge() {
    challengeGoal = <FactoryRecipeMaterialType, double>{FactoryRecipeMaterialType(FactoryMaterialType.airCondition): 1};

    gameCameraPosition.position = Offset(90.0, 300.0);
    gameCameraPosition.scale = 2.0;

    mapWidth = 4;
    mapHeight = 4;

    equipment.clear();

    equipment.add(Dispenser(Coordinates(0, 0), Direction.north, FactoryMaterialType.diamond,
        dispenseAmount: 1, isMutable: false));

    equipment.add(
        Dispenser(Coordinates(1, 1), Direction.north, FactoryMaterialType.gold, dispenseAmount: 1, isMutable: false));

    equipment.add(
        Dispenser(Coordinates(2, 2), Direction.west, FactoryMaterialType.gold, dispenseAmount: 1, isMutable: false));

    equipment.add(
        Dispenser(Coordinates(3, 3), Direction.north, FactoryMaterialType.gold, dispenseAmount: 1, isMutable: false));

    equipment.add(Dispenser(Coordinates(4, 4), Direction.west, FactoryMaterialType.aluminium,
        dispenseAmount: 1, isMutable: false));

    equipment.add(Seller(Coordinates(0, 4), Direction.west, isMutable: false));
  }

  void _loadThirdChallenge() {
    challengeGoal = <FactoryRecipeMaterialType, double>{FactoryRecipeMaterialType(FactoryMaterialType.lightBulb): 1};

    gameCameraPosition.position = Offset(120.0, 300.0);
    gameCameraPosition.scale = 2.5;

    mapWidth = 2;
    mapHeight = 3;

    equipment.clear();

    equipment.add(
        Dispenser(Coordinates(0, 0), Direction.east, FactoryMaterialType.copper, dispenseAmount: 2, isMutable: false));

    equipment.add(
        Dispenser(Coordinates(0, 3), Direction.east, FactoryMaterialType.iron, dispenseAmount: 2, isMutable: false));

    equipment.add(Seller(Coordinates(2, 0), Direction.west, isMutable: false));
  }

  void _loadFourthChallenge() {
    challengeGoal = <FactoryRecipeMaterialType, double>{FactoryRecipeMaterialType(FactoryMaterialType.engine): 1};

    gameCameraPosition.position = Offset(120.0, 300.0);
    gameCameraPosition.scale = 2.5;

    mapWidth = 2;
    mapHeight = 3;

    equipment.clear();

    equipment.add(
        Dispenser(Coordinates(0, 0), Direction.east, FactoryMaterialType.gold, dispenseAmount: 1, isMutable: false));

    equipment.add(
        Dispenser(Coordinates(0, 3), Direction.east, FactoryMaterialType.iron, dispenseAmount: 2, isMutable: false));

    equipment.add(Seller(Coordinates(2, 0), Direction.west, isMutable: false));
  }

  void _loadFifthChallenge() {
    challengeGoal = <FactoryRecipeMaterialType, double>{FactoryRecipeMaterialType(FactoryMaterialType.railway): 0.6};

    gameCameraPosition.position = Offset(80.0, 300.0);
    gameCameraPosition.scale = 2.0;

    mapWidth = 4;
    mapHeight = 4;

    equipment.clear();

    equipment.add(
        Dispenser(Coordinates(0, 0), Direction.north, FactoryMaterialType.iron, dispenseAmount: 4, isMutable: false));

    equipment.add(
        Dispenser(Coordinates(2, 0), Direction.north, FactoryMaterialType.iron, dispenseAmount: 4, isMutable: false));

    equipment.add(
        Dispenser(Coordinates(4, 0), Direction.north, FactoryMaterialType.iron, dispenseAmount: 4, isMutable: false));

    equipment.add(Seller(Coordinates(2, 4), Direction.north, isMutable: false));
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();

    _map.addAll(<String, dynamic>{'did_complete': _didComplete});

    return _map;
  }
}
