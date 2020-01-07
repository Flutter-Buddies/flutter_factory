import 'dart:io';

import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
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

      recipes = Map<FactoryMaterialType, UnLockableRecipes>.fromEntries(FactoryMaterialType.values.where((FactoryMaterialType fmt) => !FactoryMaterialModel.isRaw(fmt)).map((FactoryMaterialType type){
        return MapEntry(type,
          UnLockableRecipes(
            type,
            false,
            getRecipeCost(type),
          )
        );
      }));
      return;
    }

    print('Loading unlockables: ${unLockablesBox.toMap()}');

    final List<dynamic> machinesList = unLockablesBox.toMap()['unlockable_machines'];
    final List<dynamic> recepiesList = unLockablesBox.toMap()['unlockable_recipes'];

    machines = Map.fromEntries(machinesList.map((dynamic item){
      final EquipmentType _type = EquipmentType.values[item['equipment']];
      return MapEntry<EquipmentType, UnLockableMachines>(_type, UnLockableMachines(
        _type,
        item['unlocked'],
        item['cost'],
        item['unlock_cost']
      ));
    }));

    recipes = Map.fromEntries(recepiesList.map((dynamic item){
      final FactoryMaterialType _type = FactoryMaterialType.values[item['recepie']];
      return MapEntry<FactoryMaterialType, UnLockableRecipes>(_type, UnLockableRecipes(
        _type,
        item['unlocked'],
        item['unlock_cost']
      ));
    }));
  }

  void saveUnLockable(){
    print('Saving unlockables!');
    unLockablesBox.put('unlockable_machines', machines.values.map((UnLockableMachines m) => m.toMap()).toList());
    unLockablesBox.put('unlockable_recipes', recipes.values.map((UnLockableRecipes m) => m.toMap()).toList());
  }

  Map<EquipmentType, UnLockableMachines> machines;
  Map<FactoryMaterialType, UnLockableRecipes> recipes;

  bool isRecipeUnlocked(FactoryMaterialType type) => recipes[type].isUnlocked;
  int recipeCost(FactoryMaterialType type) => recipes[type].unlockCost;

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

  int getRecipeCost(FactoryMaterialType type){
    switch(type){
      case FactoryMaterialType.computerChip: return 360000;
      case FactoryMaterialType.engine: return 360000;
      case FactoryMaterialType.heaterPlate: return 360000;
      case FactoryMaterialType.coolerPlate: return 360000;
      case FactoryMaterialType.lightBulb: return 360000;
      case FactoryMaterialType.clock: return 540000;
      case FactoryMaterialType.antenna: return 540000;
      case FactoryMaterialType.grill: return 600000;
      case FactoryMaterialType.toaster: return 900000;
      case FactoryMaterialType.airCondition: return 900000;
      case FactoryMaterialType.battery: return 1050000;
      case FactoryMaterialType.washingMachine: return 1100000;
      case FactoryMaterialType.solarPanel: return 1170000;
      case FactoryMaterialType.headphones: return 1300000;
      case FactoryMaterialType.processor: return 1320000;
      case FactoryMaterialType.drill: return 1500000;
      case FactoryMaterialType.powerSupply: return 1920000;
      case FactoryMaterialType.speakers: return 3300000;
      case FactoryMaterialType.radio: return 5670000;
      case FactoryMaterialType.jackHammer: return 6920000;
      case FactoryMaterialType.tv: return 7100000;
      case FactoryMaterialType.smartphone: return 7300000;
      case FactoryMaterialType.fridge: return 7400000;
      case FactoryMaterialType.tablet: return 7600000;
      case FactoryMaterialType.microwave: return 8070000;
      case FactoryMaterialType.railway: return 8400000;
      case FactoryMaterialType.smartWatch: return 10000000;
      case FactoryMaterialType.serverRack: return 11000000;
      case FactoryMaterialType.computer: return 11000000;
      case FactoryMaterialType.generator: return 12000000;
      case FactoryMaterialType.waterHeater: return 13000000;
      case FactoryMaterialType.drone: return 17000000;
      case FactoryMaterialType.electricBoard: return 27000000;
      case FactoryMaterialType.oven: return 27000000;
      case FactoryMaterialType.laser: return 32000000;
      case FactoryMaterialType.superComputer: return 550000000;
      case FactoryMaterialType.advancedEngine: return 70000000;
      case FactoryMaterialType.electricEngine: return 900000000;
      case FactoryMaterialType.electricGenerator: return 470000000;
      case FactoryMaterialType.aiProcessor: return 2500000000;
      case FactoryMaterialType.robotHead: return 5000000000;
      case FactoryMaterialType.robotBody: return 2800000000;
      case FactoryMaterialType.robot: return 15000000000;
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

class UnLockableRecipes{
  UnLockableRecipes(this.recipeType, this.isUnlocked, this.unlockCost);

  FactoryMaterialType recipeType;
  bool isUnlocked;
  int unlockCost;

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      'recepie': recipeType.index,
      'unlocked': isUnlocked,
      'unlock_cost': unlockCost
    };
  }
}