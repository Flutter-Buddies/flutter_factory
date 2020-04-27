import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';

abstract class MoneyManager {
  int currentCredit = 0;
  int idleCredit = 0;
  bool hasClaimedCredit = false;

  void reset() {
    hasClaimedCredit = false;
    idleCredit = 0;
    currentCredit = 10000;
  }

  void getIdleEarnings(Map<dynamic, dynamic> _result, int _tickSpeed);

  void claimIdleCredit({double multiple = 1.0});

  void tickEarned(int tickMoney);

  int costOfEquipment(EquipmentType type);

  int costOfUnlockingEquipment(EquipmentType type);

  int costOfRecipe(FactoryMaterialType type);

  bool isRecipeUnlocked(FactoryMaterialType type);

  bool isEquipmentUnlocked(EquipmentType type);

  void buyEquipment(EquipmentType equipmentType, {int bulkBuy = 1});

  void buy(int cost);

  void sellEquipment(EquipmentType equipmentType, {int bulkSell = 1});

  bool canPurchase(int totalCost);

  bool canPurchaseEquipment(EquipmentType equipmentType, {int bulkBuy = 1});

  bool canUnlockRecipe(FactoryMaterialType type);

  bool canUnlockEquipment(EquipmentType type);

  void unlockRecipe(FactoryMaterialType type);

  void unlockEquipment(EquipmentType type);

  void save();
}
