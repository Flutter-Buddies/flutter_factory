import 'dart:convert';
import 'dart:ui';

import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/game/money_manager/sandbox_manager.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/util/utils.dart';
import 'package:hive/hive.dart';
import 'package:random_color/random_color.dart';

import 'game/model/factory_equipment_model.dart';

class SandboxBloc extends GameBloc {
  SandboxBloc() : super(moneyManager: SandboxManager()) {
    loadFactoryFloor();
  }

  @override
  String getFloorName({int floor}) {
    return 'Sandbox ${(floor ?? factoryFloor) + 1}';
  }

  @override
  Future<void> saveFactory() async {
    if (!hiveBox.isOpen) {
      hiveBox = await Hive.openBox<dynamic>('sandbox_$factoryFloor');
    }

    await hiveBox.putAll(toMap());
    await hiveBox.compact();
  }

  final int mapSize = 500;

  @override
  Future<void> loadFactoryFloor() async {
    mapHeight = mapSize;
    mapWidth = mapSize;

    print('Loading factory from DB!');

    hiveBox = await Hive.openBox<dynamic>('sandbox_$factoryFloor');

    print(hiveBox.toMap());
    final Map<dynamic, dynamic> _result = hiveBox.toMap();

    if (_result.isEmpty) {
      equipment.clear();
      return;
    }

    final List<dynamic> _equipmentList = _result['equipment'];
    print('Loaded equipment: ${_equipmentList.length}');

    equipment.clear();
    equipment.addAll(_equipmentList.map((dynamic eq) {
      final FactoryEquipmentModel _fem = equipmentFromMap(eq);
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

    void _findPortals(UndergroundPortal up) {
      final UndergroundPortal _connectingPortal =
          _portals.firstWhere((UndergroundPortal _up) => _up.coordinates == up.connectingPortal, orElse: () => null);

      if (_connectingPortal != null) {
        _connectingPortal.connectingPortal = up.coordinates;
        up.connectingPortal = _connectingPortal.coordinates;

        final Color _lineColor = RandomColor().randomColor();

        _connectingPortal.lineColor = _lineColor;
        up.lineColor = _lineColor;
      }
    }

    _portals.forEach(_findPortals);

    print(_result);
  }

  void restart() async {
    await hiveBox.clear();
    loadFactoryFloor();
  }
}
