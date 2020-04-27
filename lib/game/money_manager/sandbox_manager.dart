import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/game/money_manager/money_manager.dart';

class SandboxManager extends MoneyManager {
  @override
  void getIdleEarnings(Map<dynamic, dynamic> _result, int _tickSpeed) {
    /// Sandbox mode
  }

  @override
  void claimIdleCredit({double multiple = 1.0}) {}

  @override
  void tickEarned(int tickMoney) {
    /// Sandobx mode, show only earnings per tick
    currentCredit = tickMoney;
  }

  @override
  int costOfEquipment(EquipmentType type) {
    return 0;
  }

  @override
  int costOfUnlockingEquipment(EquipmentType type) {
    return 0;
  }

  @override
  int costOfRecipe(FactoryMaterialType type) {
    return 0;
  }

  @override
  bool isRecipeUnlocked(FactoryMaterialType type) {
    return true;
  }

  @override
  bool isEquipmentUnlocked(EquipmentType type) {
    return true;
  }

  @override
  void buyEquipment(EquipmentType equipmentType, {int bulkBuy = 1}) {}

  @override
  void buy(int cost) {}

  @override
  void sellEquipment(EquipmentType equipmentType, {int bulkSell = 1}) {}

  @override
  bool canPurchase(int totalCost) {
    return true;
  }

  @override
  bool canPurchaseEquipment(EquipmentType equipmentType, {int bulkBuy = 1}) {
    return true;
  }

  @override
  bool canUnlockRecipe(FactoryMaterialType type) {
    return true;
  }

  @override
  bool canUnlockEquipment(EquipmentType type) {
    return true;
  }

  @override
  void unlockRecipe(FactoryMaterialType type) {}

  @override
  void unlockEquipment(EquipmentType type) {}

  @override
  void save() {}
}
