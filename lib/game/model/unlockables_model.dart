import 'dart:io';

import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class GameItems{
  GameItems(){
    _openHive();
  }

  Box<dynamic> unLockablesBox;

  void _openHive() async {
    final Directory _path = await getApplicationDocumentsDirectory();

    Hive.init(_path.path);

    unLockablesBox = await Hive.openBox<dynamic>('unlockables');

    if(unLockablesBox.isEmpty){
      machines = Map<EquipmentType, UnLockableMachines>.fromEntries(EquipmentType.values.map((EquipmentType type){
        return MapEntry(type,
          UnLockableMachines(
            type,
            machineUnlocked(type),
            getMachineCost(type),
            getMachineUnlockCost(type)
          )
        );
      }));
      return;
    }

    print('Loading unlockables: ${unLockablesBox.toMap()}');

    final List<dynamic> machinesList = unLockablesBox.toMap()['unlockables'];

    machines = Map.fromEntries(machinesList.map((dynamic item){
      final EquipmentType _type = EquipmentType.values[item['equipment']];
      return MapEntry<EquipmentType, UnLockableMachines>(_type, UnLockableMachines(
        _type,
        item['unlocked'],
        item['cost'],
        item['unlock_cost']
      ));
    }));
  }

  void saveUnLockable(){
    print('Saving unlockables!');
    unLockablesBox.put('unlockables', machines.values.map((UnLockableMachines m) => m.toMap()).toList());
  }

  Map<EquipmentType, UnLockableMachines> machines;

  bool isUnlocked(EquipmentType type) => machines[type].isUnlocked;
  int cost(EquipmentType type) => machines[type].cost;
  int unlockCost(EquipmentType type) => machines[type].unlockCost;

  int getMachineCost(EquipmentType type){
    switch(type){
      case EquipmentType.dispenser:
        return 1000;
      case EquipmentType.roller:
        return 300;
      case EquipmentType.freeRoller:
        return 2500;
      case EquipmentType.crafter:
        return 20000;
      case EquipmentType.splitter:
        return 10000;
      case EquipmentType.sorter:
        return 150000;
      case EquipmentType.hydraulic_press:
        return 10000;
      case EquipmentType.wire_bender:
        return 10000;
      case EquipmentType.seller:
        return 5000;
      case EquipmentType.cutter:
        return 10000;
      case EquipmentType.melter:
        return 10000;
      case EquipmentType.rotatingFreeRoller:
        return 5000;
      case EquipmentType.portal:
        return 1000000;
      default: return 0;
    }
  }

  int getMachineUnlockCost(EquipmentType type){
    switch(type){
      case EquipmentType.roller:
        return 5000;
      case EquipmentType.freeRoller:
        return 1000000;
      case EquipmentType.crafter:
        return 80000;
      case EquipmentType.splitter:
        return 100000;
      case EquipmentType.sorter:
        return 500000;
      case EquipmentType.hydraulic_press:
        return 300000;
      case EquipmentType.wire_bender:
        return 30000;
      case EquipmentType.cutter:
        return 30000;
      case EquipmentType.melter:
        return 20000;
      case EquipmentType.rotatingFreeRoller:
        return 2000000;
      case EquipmentType.portal:
        return 250000000;
      default: return 0;
    }
  }

  bool machineUnlocked(EquipmentType type){
    switch(type){
      case EquipmentType.dispenser:
      case EquipmentType.seller:
        return true;
      default:
        return false;
    }
  }
}

class UnLockableMachines{
  UnLockableMachines(this.equipment, this.isUnlocked, this.cost, this.unlockCost);

  EquipmentType equipment;
  bool isUnlocked;
  int cost;
  int unlockCost;

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      'equipment': equipment.index,
      'unlocked': isUnlocked,
      'cost': cost,
      'unlock_cost': unlockCost
    };
  }
}