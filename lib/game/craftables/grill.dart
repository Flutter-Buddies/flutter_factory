import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Grill extends FactoryMaterial{
  Grill.fromOffset(Offset o) : super(o.dx, o.dy, 540.0, FactoryMaterialType.grill, state: FactoryMaterialState.crafted);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.7;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRRect(RRect.fromRectAndRadius(Rect.fromPoints(
      Offset(_size * 0.8, _size * 0.8),
      Offset(-_size * 0.8, -_size * 0.8),
    ), Radius.circular(_size * 0.4)));

    canvas.drawPath(_frame, _p..color = Colors.red.shade200.withOpacity(opacity));

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);


    for(int i = 0; i < 6; i++){
      canvas.drawLine(
        Offset(_size * 0.6 - (_size * 1.2 * (i / 5)), _size * 0.8),
        Offset(_size * 0.6 - (_size * 1.2 * (i / 5)), -_size * 0.8),
        _p..strokeWidth = 0.2
      );
    }

    canvas.drawLine(
      Offset(
        _size * 0.8,
        0.0
      ),
      Offset(
        -_size * 0.8,
        0.0
      ), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.heaterPlate): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.iron): 4,
    };
  }
}