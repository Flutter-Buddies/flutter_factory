import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';

class ObjectPainter extends CustomPainter{
  ObjectPainter(this.progress, {this.objectSize = 48.0, this.equipment, this.material});

  final FactoryMaterialModel material;
  final FactoryEquipmentModel equipment;

  final double objectSize;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if(material != null){
      material.drawMaterial(Offset.zero, canvas, progress);
    }

    if(equipment != null){
      equipment.drawTrack(Offset.zero, canvas, objectSize, progress);
      equipment.drawMaterial(Offset.zero, canvas, objectSize, progress);
      equipment.drawEquipment(Offset.zero, canvas, objectSize, progress);
    }
  }

  @override
  bool shouldRepaint(ObjectPainter oldDelegate) {
    return oldDelegate.material != material || oldDelegate.equipment != equipment || oldDelegate.progress != progress || oldDelegate.objectSize != objectSize;
  }
}