import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Clock extends FactoryMaterial{
  Clock.fromOffset(Offset o) : super(o.dx, o.dy, 540.0, FactoryMaterialType.clock, state: FactoryMaterialState.crafted);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addOval(Rect.fromPoints(
      Offset(_size * 0.8, _size * 0.8),
      Offset(-_size * 0.8, -_size * 0.8),
    ));

    final Path _clockHands = Path();

    _clockHands.moveTo(0.0, 0.0);
    _clockHands.lineTo(_size * 0.3, -_size * 0.3);

    _clockHands.moveTo(0.0, 0.0);
    _clockHands.lineTo(0.0, -_size * 0.6);

    canvas.drawPath(_frame, _p..color = Colors.grey.withOpacity(opacity));

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);
    canvas.drawPath(_clockHands, _p..strokeWidth = .4);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.iron): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.gold): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.copper, state: FactoryMaterialState.gear): 1,
    };
  }
}