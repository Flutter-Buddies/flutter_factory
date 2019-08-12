import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Drone extends FactoryMaterial{
  Drone.fromOffset(Offset o) : super(o.dx, o.dy, 13000.0, FactoryMaterialType.drone, state: FactoryMaterialState.crafted);

  Drone.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.raw, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.drone, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRect(Rect.fromPoints(
      Offset(_size * 0.5, _size * 0.25),
      Offset(-_size * 0.5, -_size * 0.25),
    ));

    _frame.moveTo(-_size * 0.5, -_size * 0.25);
    _frame.lineTo(-_size * 0.9, -_size * 0.9);

    _frame.moveTo(-_size * 0.5, _size * 0.25);
    _frame.lineTo(-_size * 0.9, _size * 0.9);

    _frame.moveTo(_size * 0.5, -_size * 0.25);
    _frame.lineTo(_size * 0.9, -_size * 0.9);

    _frame.moveTo(_size * 0.5, _size * 0.25);
    _frame.lineTo(_size * 0.9, _size * 0.9);

    canvas.drawPath(_frame, _p..color = Colors.grey.shade300.withOpacity(opacity));

    _p.color = Colors.black54.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.stroke;
    _p.strokeCap = StrokeCap.round;
    canvas.drawPath(_frame, _p);

    _p.color = Colors.white54;
    _p.strokeCap = StrokeCap.round;
    _p.strokeWidth = 0.2;

    canvas.drawCircle(Offset(-_size * 0.9, -_size * 0.9), 4.2, _p);
    canvas.drawCircle(Offset(-_size * 0.9, _size * 0.9), 4.2, _p);
    canvas.drawCircle(Offset(_size * 0.9, -_size * 0.9), 4.2, _p);
    canvas.drawCircle(Offset(_size * 0.9, _size * 0.9), 4.2, _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.battery): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.processor): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium, state: FactoryMaterialState.plate): 4,
    };
  }

  @override
  FactoryMaterial copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Drone.custom(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      value: value ?? this.value,
      state: this.state,
      rotation: this.rotation,
      offsetX: this.offsetX,
      offsetY: this.offsetY,
    );
  }
}