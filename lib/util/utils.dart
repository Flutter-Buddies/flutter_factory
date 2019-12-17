import 'dart:convert';
import 'dart:ui';

import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/factory_material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';

FactoryEquipmentModel equipmentFromMap(String jsonMap){
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


FactoryMaterialModel materialFromMap(Map<String, dynamic> map){
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
