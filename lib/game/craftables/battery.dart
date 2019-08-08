import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Battery extends FactoryMaterial{
  Battery.fromOffset(Offset o) : super(o.dx, o.dy, 120.0, FactoryMaterialType.battery, state: FactoryMaterialState.crafted);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();
    double _size = size * 0.4;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _p.color = Colors.green.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.75, _size * 0.5), Offset(-_size * 0.9, -_size * 0.5)), _p);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.75, _size * 0.2), Offset(_size * 0.9, -_size * 0.2)), _p);

    canvas.restore();
  }
}