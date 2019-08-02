import 'package:flutter_factory/game/equipment/crafter.dart';
import 'package:flutter_factory/game/equipment/cutter.dart';
import 'package:flutter_factory/game/equipment/dispenser.dart';
import 'package:flutter_factory/game/equipment/hydraulic_press.dart';
import 'package:flutter_factory/game/equipment/roller.dart';
import 'package:flutter_factory/game/equipment/sorter.dart';
import 'package:flutter_factory/game/equipment/splitter.dart';
import 'package:flutter_factory/game/equipment/wire_bender.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

List<FactoryEquipment> buildDummy(){
  return <FactoryEquipment>[
    Dispenser(Coordinates(1, 2), Direction.north, FactoryMaterialType.copper, dispenseAmount: 3),
    Dispenser(Coordinates(2, 2), Direction.north, FactoryMaterialType.gold, dispenseAmount: 2),
    Dispenser(Coordinates(3, 2), Direction.north, FactoryMaterialType.iron),
    Dispenser(Coordinates(5, 2), Direction.north, FactoryMaterialType.diamond),

    Splitter(Coordinates(1, 3), Direction.east, <Direction>[Direction.east, Direction.north]),
    Roller(Coordinates(2, 3), Direction.east),
    Roller(Coordinates(3, 3), Direction.east),
    Roller(Coordinates(4, 3), Direction.east),
    Roller(Coordinates(5, 3), Direction.east),

    Sorter(Coordinates(6, 3), Direction.east, <FactoryMaterialType, Direction>{FactoryMaterialType.gold: Direction.north}),
    Roller(Coordinates(6, 4), Direction.north),
    Roller(Coordinates(6, 5), Direction.north),

    Roller(Coordinates(7, 3), Direction.east),
    Roller(Coordinates(8, 3), Direction.north),
    Roller(Coordinates(8, 4), Direction.north),
    Splitter(Coordinates(8, 5), Direction.north, <Direction>[Direction.north, Direction.east, Direction.west]),

    Roller(Coordinates(1, 4), Direction.north),
    Roller(Coordinates(1, 5), Direction.north),
    Roller(Coordinates(1, 6), Direction.east),

    Dispenser(Coordinates(1, 7), Direction.east, FactoryMaterialType.copper, dispenseAmount: 2),
    Splitter(Coordinates(2, 7), Direction.east, <Direction>[Direction.south, Direction.north]),
    Roller(Coordinates(2, 6), Direction.east),
    Roller(Coordinates(2, 8), Direction.east),
    Roller(Coordinates(3, 6), Direction.east),
    Roller(Coordinates(3, 8), Direction.east),
    Roller(Coordinates(4, 6), Direction.east),
    Roller(Coordinates(4, 8), Direction.east),
    Roller(Coordinates(5, 6), Direction.east),
    Roller(Coordinates(5, 8), Direction.east),

    Dispenser(Coordinates(3, 7), Direction.east, FactoryMaterialType.gold, dispenseAmount: 2),
    Roller(Coordinates(4, 7), Direction.east),
    Roller(Coordinates(5, 7), Direction.east),
    Splitter(Coordinates(6, 7), Direction.east, <Direction>[Direction.south, Direction.north]),

    Crafter(Coordinates(6, 8), Direction.east, FactoryMaterialType.computerChip),
    Crafter(Coordinates(6, 6), Direction.east, FactoryMaterialType.computerChip),

    Dispenser(Coordinates(2, 10), Direction.north, FactoryMaterialType.copper, dispenseTickDuration: 1, dispenseAmount: 1),
    Dispenser(Coordinates(3, 10), Direction.north, FactoryMaterialType.gold, dispenseTickDuration: 2, dispenseAmount: 2),
    Dispenser(Coordinates(4, 10), Direction.north, FactoryMaterialType.copper, dispenseTickDuration: 3, dispenseAmount: 3),
    Dispenser(Coordinates(5, 10), Direction.north, FactoryMaterialType.gold, dispenseTickDuration: 1, dispenseAmount: 2),
    Dispenser(Coordinates(6, 10), Direction.north, FactoryMaterialType.copper, dispenseTickDuration: 1, dispenseAmount: 4),


    Roller(Coordinates(2, 11), Direction.east),
    Roller(Coordinates(3, 11), Direction.east),
    Roller(Coordinates(4, 11), Direction.east),
    Roller(Coordinates(5, 11), Direction.east),
    Roller(Coordinates(6, 11), Direction.east),
    Roller(Coordinates(7, 11), Direction.east),
    Roller(Coordinates(8, 11), Direction.east),
    Roller(Coordinates(9, 11), Direction.east),
    Roller(Coordinates(10, 11), Direction.east),
    Splitter(Coordinates(11, 11), Direction.east, <Direction>[Direction.east, Direction.east, Direction.east, Direction.east, Direction.east, Direction.east, Direction.south, Direction.north]),
    Splitter(Coordinates(12, 11), Direction.east, <Direction>[Direction.east, Direction.east, Direction.east, Direction.east, Direction.south, Direction.north]),
    Splitter(Coordinates(13, 11), Direction.east, <Direction>[Direction.east, Direction.south, Direction.north]),

    WireBender(Coordinates(11, 12), Direction.north),
    HydraulicPress(Coordinates(12, 12), Direction.north),
    Cutter(Coordinates(13, 12), Direction.north),
  ];
}

List<FactoryEquipment> buildStressTestChipProduction(){
  final List<FactoryEquipment> _equipment = <FactoryEquipment>[];

  _equipment.addAll(buildChipProduction());
  _equipment.addAll(buildChipProduction(xOffset: 10));
  _equipment.addAll(buildChipProduction(yOffset: 10));
  _equipment.addAll(buildChipProduction(xOffset: 10, yOffset: 10));

  _equipment.add(Roller(Coordinates(4, 11), Direction.north));
  _equipment.add(Roller(Coordinates(4, 12), Direction.north));
  _equipment.add(Roller(Coordinates(4, 13), Direction.north));
  _equipment.add(Roller(Coordinates(4, 14), Direction.north));

  _equipment.add(Roller(Coordinates(14, 11), Direction.north));
  _equipment.add(Roller(Coordinates(14, 12), Direction.north));
  _equipment.add(Roller(Coordinates(14, 13), Direction.north));
  _equipment.add(Roller(Coordinates(14, 14), Direction.north));

  _equipment.add(Roller(Coordinates(4, 21), Direction.north));
  _equipment.add(Roller(Coordinates(14, 21), Direction.north));

  _equipment.add(Roller(Coordinates(4, 22), Direction.east));
  _equipment.add(Roller(Coordinates(5, 22), Direction.east));
  _equipment.add(Roller(Coordinates(6, 22), Direction.east));
  _equipment.add(Roller(Coordinates(7, 22), Direction.east));
  _equipment.add(Roller(Coordinates(8, 22), Direction.east));
  _equipment.add(Roller(Coordinates(9, 22), Direction.east));
  _equipment.add(Roller(Coordinates(10, 22), Direction.east));
  _equipment.add(Roller(Coordinates(11, 22), Direction.east));
  _equipment.add(Roller(Coordinates(12, 22), Direction.east));
  _equipment.add(Roller(Coordinates(13, 22), Direction.east));
  _equipment.add(Roller(Coordinates(14, 22), Direction.east));
  _equipment.add(Roller(Coordinates(15, 22), Direction.east));
  _equipment.add(Roller(Coordinates(16, 22), Direction.east));
  _equipment.add(Roller(Coordinates(17, 22), Direction.east));
  _equipment.add(Roller(Coordinates(18, 22), Direction.east));
  _equipment.add(Roller(Coordinates(19, 22), Direction.east));
  _equipment.add(Roller(Coordinates(20, 22), Direction.east));
  _equipment.add(Roller(Coordinates(21, 22), Direction.east));
  _equipment.add(Roller(Coordinates(22, 22), Direction.east));

  _equipment.add(Roller(Coordinates(23, 22), Direction.south));
  _equipment.add(Roller(Coordinates(23, 21), Direction.south));
  _equipment.add(Roller(Coordinates(23, 20), Direction.south));
  _equipment.add(Roller(Coordinates(23, 19), Direction.south));
  _equipment.add(Roller(Coordinates(23, 18), Direction.south));
  _equipment.add(Roller(Coordinates(23, 17), Direction.south));
  _equipment.add(Roller(Coordinates(23, 16), Direction.south));
  _equipment.add(Roller(Coordinates(23, 15), Direction.south));
  _equipment.add(Roller(Coordinates(23, 14), Direction.south));

  return _equipment;
}

List<FactoryEquipment> buildChipProduction({int xOffset = 0, int yOffset = 0}){
  return <FactoryEquipment>[
    Dispenser(Coordinates(xOffset + 1, yOffset + 2), Direction.north, FactoryMaterialType.copper, dispenseAmount: 3),
    Splitter(Coordinates(xOffset + 1, yOffset + 3), Direction.north, <Direction>[Direction.north, Direction.north, Direction.east]),
    Splitter(Coordinates(xOffset + 1, yOffset + 4), Direction.north, <Direction>[Direction.north, Direction.east]),

    WireBender(Coordinates(xOffset + 2, yOffset + 3), Direction.east),
    WireBender(Coordinates(xOffset + 2, yOffset + 4), Direction.north),
    WireBender(Coordinates(xOffset + 1, yOffset + 5), Direction.east),

    Crafter(Coordinates(xOffset + 2, yOffset + 5), Direction.east, FactoryMaterialType.computerChip, craftingTickDuration: 1),
    Crafter(Coordinates(xOffset + 3, yOffset + 6), Direction.east, FactoryMaterialType.computerChip, craftingTickDuration: 1),
    Crafter(Coordinates(xOffset + 2, yOffset + 7), Direction.east, FactoryMaterialType.computerChip, craftingTickDuration: 1),

    Dispenser(Coordinates(xOffset + 1, yOffset + 6), Direction.east, FactoryMaterialType.gold, dispenseAmount: 3),
    Splitter(Coordinates(xOffset + 2, yOffset + 6), Direction.east, <Direction>[Direction.north, Direction.east, Direction.south]),


    Dispenser(Coordinates(xOffset + 1, yOffset + 10), Direction.south, FactoryMaterialType.copper, dispenseAmount: 3),
    Splitter(Coordinates(xOffset + 1, yOffset + 9), Direction.south, <Direction>[Direction.south, Direction.south, Direction.east]),
    Splitter(Coordinates(xOffset + 1, yOffset + 8), Direction.south, <Direction>[Direction.south, Direction.east]),

    WireBender(Coordinates(xOffset + 2, yOffset + 9), Direction.east),
    WireBender(Coordinates(xOffset + 2, yOffset + 8), Direction.south),
    WireBender(Coordinates(xOffset + 1, yOffset + 7), Direction.east),

    Roller(Coordinates(xOffset + 3, yOffset + 3), Direction.north),
    Roller(Coordinates(xOffset + 3, yOffset + 4), Direction.north),
    Sorter(Coordinates(xOffset + 3, yOffset + 5), Direction.north, <FactoryMaterialType, Direction>{FactoryMaterialType.computerChip: Direction.east}),


    Sorter(Coordinates(xOffset + 3, yOffset + 7), Direction.south, <FactoryMaterialType, Direction>{FactoryMaterialType.computerChip: Direction.east}),
    Roller(Coordinates(xOffset + 3, yOffset + 8), Direction.south),
    Roller(Coordinates(xOffset + 3, yOffset + 9), Direction.south),

    Roller(Coordinates(xOffset + 4, yOffset + 5), Direction.north),
    Roller(Coordinates(xOffset + 4, yOffset + 6), Direction.north),
    Roller(Coordinates(xOffset + 4, yOffset + 7), Direction.north),
    Roller(Coordinates(xOffset + 4, yOffset + 8), Direction.north),
    Roller(Coordinates(xOffset + 4, yOffset + 9), Direction.north),
    Roller(Coordinates(xOffset + 4, yOffset + 10), Direction.north),

    Cutter(Coordinates(xOffset + 5, yOffset + 4), Direction.north),
    Splitter(Coordinates(xOffset + 6, yOffset + 4), Direction.west, <Direction>[Direction.west, Direction.north]),
    Splitter(Coordinates(xOffset + 7, yOffset + 4), Direction.west, <Direction>[Direction.west, Direction.west, Direction.north]),

    Dispenser(Coordinates(xOffset + 8, yOffset + 4), Direction.west, FactoryMaterialType.iron, dispenseAmount: 1, dispenseTickDuration: 1),
    Dispenser(Coordinates(xOffset + 9, yOffset + 5), Direction.north, FactoryMaterialType.iron, dispenseAmount: 1, dispenseTickDuration: 1),
    Dispenser(Coordinates(xOffset + 5, yOffset + 8), Direction.south, FactoryMaterialType.gold, dispenseAmount: 1, dispenseTickDuration: 1),

    Crafter(Coordinates(xOffset + 5, yOffset + 5), Direction.west, FactoryMaterialType.engine, craftingTickDuration: 1),
    Crafter(Coordinates(xOffset + 7, yOffset + 6), Direction.north, FactoryMaterialType.engine, craftingTickDuration: 1),
    Crafter(Coordinates(xOffset + 8, yOffset + 8), Direction.north, FactoryMaterialType.engine, craftingTickDuration: 1),

    Cutter(Coordinates(xOffset + 6, yOffset + 5), Direction.west),
    Cutter(Coordinates(xOffset + 7, yOffset + 5), Direction.north),
    Cutter(Coordinates(xOffset + 8, yOffset + 6), Direction.west),
    Cutter(Coordinates(xOffset + 5, yOffset + 6), Direction.south),
    Cutter(Coordinates(xOffset + 6, yOffset + 6), Direction.east),

    Splitter(Coordinates(xOffset + 9, yOffset + 6), Direction.north, <Direction>[Direction.north, Direction.north, Direction.west]),
    Splitter(Coordinates(xOffset + 9, yOffset + 7), Direction.north, <Direction>[Direction.north, Direction.west]),

    Splitter(Coordinates(xOffset + 5, yOffset + 7), Direction.south, <Direction>[Direction.south, Direction.east, Direction.east]),
    Splitter(Coordinates(xOffset + 6, yOffset + 7), Direction.east, <Direction>[Direction.south, Direction.north]),

    Cutter(Coordinates(xOffset + 8, yOffset + 7), Direction.north),
    Cutter(Coordinates(xOffset + 9, yOffset + 8), Direction.west),

    Cutter(Coordinates(xOffset + 6, yOffset + 8), Direction.east),
    Roller(Coordinates(xOffset + 7, yOffset + 7), Direction.north),

    Sorter(Coordinates(xOffset + 7, yOffset + 8), Direction.north, <FactoryMaterialType, Direction>{FactoryMaterialType.gold: Direction.east}),

    Roller(Coordinates(xOffset + 5, yOffset + 9), Direction.west),
    Roller(Coordinates(xOffset + 6, yOffset + 9), Direction.west),
    Roller(Coordinates(xOffset + 7, yOffset + 9), Direction.west),
    Roller(Coordinates(xOffset + 8, yOffset + 9), Direction.west),
  ];
}