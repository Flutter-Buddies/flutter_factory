import 'dart:convert';

import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/util/utils.dart';

class ChallengeModel {
  ChallengeModel({this.challengeName, this.author, this.challengeGoal, this.bannedEquipment, this.equipmentPlacement});

  ChallengeModel.fromJson(Map<String, dynamic> json) {
    challengeName = json['challenge_name'];
    author = json['author'];
    if (json['challenge_goal'] != null) {
      challengeGoal = <ChallengeGoal>[];
      json['challenge_goal'].forEach((dynamic v) {
        challengeGoal.add(new ChallengeGoal.fromJson(v));
      });
    }
    bannedEquipment = json['banned_equipment'].cast<int>()..map((int i) => EquipmentType.values[i]).toList();
    if (json['equipment_placement'] != null) {
      equipmentPlacement = json['equipment_placement'].map((dynamic eq) {
        final FactoryEquipmentModel _fem = equipmentFromMap(eq);
        final Map<String, dynamic> map = jsonDecode(eq);

        final List<dynamic> _materialMap = map['material'];
        final List<FactoryMaterialModel> _materials = _materialMap.map((dynamic map) {
          final FactoryMaterialModel _material = materialFromMap(map);
          _material.direction ??= _fem.direction;
          return _material;
        }).toList();

        _fem.objects.addAll(_materials);

        return _fem;
      }).toList();
    }
  }

  String challengeName;
  String author;
  List<ChallengeGoal> challengeGoal;
  List<EquipmentType> bannedEquipment;
  List<FactoryEquipmentModel> equipmentPlacement;

  int mapWidth;
  int mapHeight;

  double cameraPositionX, cameraPositionY;
  double cameraScale;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['challenge_name'] = challengeName;
    data['author'] = author;
    if (challengeGoal != null) {
      data['challenge_goal'] = challengeGoal.map((ChallengeGoal v) => v.toJson()).toList();
    }
    data['banned_equipment'] = bannedEquipment.map((EquipmentType e) => e.index).toList();
    if (equipmentPlacement != null) {
      data['equipment_placement'] = equipmentPlacement.map((FactoryEquipmentModel v) => v.toMap()).toList();
    }
    return data;
  }

  String getChallengeDescription() {
    if (challengeGoal == null || challengeGoal.isEmpty) {
      return '';
    }

    final StringBuffer _sb = StringBuffer();

    _sb.write('You have to produce ');

    void _appendBuilder(ChallengeGoal goal) {
      _sb.write('${goal.perTick} ${factoryMaterialToString(goal.materialType)}');
    }

    challengeGoal.forEach(_appendBuilder);
    _sb.write(' per tick');

    return _sb.toString();
  }

  String getChallengeLongDescription() {
    if (challengeGoal == null || challengeGoal.isEmpty) {
      return '';
    }

    final StringBuffer _sb = StringBuffer();

    _sb.write('You have to use the space given to you, and build production line that will output ');

    void _appendBuilder(ChallengeGoal goal) {
      _sb.write('${goal.perTick} ${factoryMaterialToString(goal.materialType)}');
    }

    challengeGoal.forEach(_appendBuilder);
    _sb.write(' per tick.');

    return _sb.toString();
  }
}

class ChallengeGoal {
  ChallengeGoal({this.materialType, this.perTick});

  ChallengeGoal.fromJson(Map<String, dynamic> json) {
    materialType = FactoryMaterialType.values[json['material_type']];
    perTick = json['per_tick'];
  }

  FactoryMaterialType materialType;
  double perTick;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['material_type'] = materialType.index;
    data['per_tick'] = perTick;
    return data;
  }
}
