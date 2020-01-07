import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/ui/theme/game_theme.dart';
import 'package:flutter_factory/ui/theme/themes/light_game_theme.dart';

class ObjectPainter extends CustomPainter{
  ObjectPainter(this.progress, {@required this.theme, this.objectSize = 48.0, this.scale = 1.0, this.equipment, this.material});

  final FactoryMaterialModel material;
  final FactoryEquipmentModel equipment;

  final double objectSize;
  final double progress;
  final GameTheme theme;

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);

    if(material != null){
      material.size = objectSize;
      material.drawMaterial(Offset.zero, canvas, progress);
    }

    if(equipment != null){
      equipment.drawTrack(theme, Offset.zero, canvas, objectSize, progress);
      equipment.drawMaterial(theme, Offset.zero, canvas, objectSize, progress);
      equipment.drawEquipment(theme, Offset.zero, canvas, objectSize, progress);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ObjectPainter oldDelegate) {
    return oldDelegate.material != material || oldDelegate.equipment != equipment || oldDelegate.progress != progress || oldDelegate.objectSize != objectSize;
  }
}