import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/game/model/unlockables_model.dart';
import 'package:flutter_factory/game/money_manager/money_manager.dart';

class NormalMoneyManager extends MoneyManager {
  NormalMoneyManager() {
    _items = GameItems();
  }

  GameItems _items;

  @override
  void getIdleEarnings(Map<dynamic, dynamic> _result, int _tickSpeed) {
    final DateTime _collectionTime = DateTime.now();
    final DateTime _lastCollection = _result['last_collection'] ?? _collectionTime;

    currentCredit = _result['floor_credit'] ?? 10000;
    idleCredit = (((_collectionTime.subtract(Duration(milliseconds: _lastCollection.millisecondsSinceEpoch)))
                        .millisecondsSinceEpoch /
                    _tickSpeed)
                .round() *
            (_result['average_earnings'] ?? 0))
        .round();

    print('Loaded credit: $currentCredit');
    print(
        'Difference in ticks: ${((_collectionTime.subtract(Duration(milliseconds: _lastCollection.millisecondsSinceEpoch))).millisecondsSinceEpoch / _tickSpeed).round()}');
    print('Average earnings per tick: ${_result['average_earnings']}');
    print('Idle credit: $idleCredit');
  }

  @override
  void claimIdleCredit({double multiple = 1.0}) {
    if (idleCredit != 0) {
      print('Added credit: ${(idleCredit * multiple).round()}');
      currentCredit += (idleCredit * multiple).round();
      idleCredit = 0;
    }
  }

  @override
  void tickEarned(int tickMoney) {
    currentCredit += tickMoney;
  }

  @override
  int costOfEquipment(EquipmentType type) {
    return _items.cost(type);
  }

  @override
  int costOfUnlockingEquipment(EquipmentType type) {
    return _items.unlockCost(type);
  }

  @override
  int costOfRecipe(FactoryMaterialType type) {
    return _items.recipeCost(type);
  }

  @override
  bool isRecipeUnlocked(FactoryMaterialType type) {
    return _items.isRecipeUnlocked(type);
  }

  @override
  bool isEquipmentUnlocked(EquipmentType type) {
    return _items.isUnlocked(type);
  }

  @override
  void buyEquipment(EquipmentType equipmentType, {int bulkBuy = 1}) {
    currentCredit -= bulkBuy * _items.cost(equipmentType);
  }

  @override
  void buy(int cost) {
    currentCredit -= cost;
  }

  @override
  void sellEquipment(EquipmentType equipmentType, {int bulkSell = 1}) {
    currentCredit += bulkSell * (_items.cost(equipmentType) ~/ 2);
  }

  @override
  bool canPurchase(int totalCost) {
    return currentCredit >= totalCost;
  }

  @override
  bool canPurchaseEquipment(EquipmentType equipmentType, {int bulkBuy = 1}) {
    return currentCredit >= (bulkBuy * _items.cost(equipmentType));
  }

  @override
  bool canUnlockRecipe(FactoryMaterialType type) {
    return currentCredit >= _items.recipeCost(type);
  }

  @override
  bool canUnlockEquipment(EquipmentType type) {
    return currentCredit >= _items.unlockCost(type);
  }

  @override
  void unlockRecipe(FactoryMaterialType type) {
    if (canUnlockRecipe(type)) {
      _items.recipes[type].isUnlocked = true;
      currentCredit -= _items.recipeCost(type);
    }
  }

  @override
  void unlockEquipment(EquipmentType type) {
    if (canUnlockEquipment(type)) {
      _items.machines[type].isUnlocked = true;
      currentCredit -= _items.unlockCost(type);
    }
  }

  @override
  void save() {
    _items.saveUnLockable();
  }
}
