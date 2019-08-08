import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class LightBulb extends FactoryMaterial{
  LightBulb.fromOffset(Offset o) : super(o.dx, o.dy, 200.0, FactoryMaterialType.lightBulb, state: FactoryMaterialState.crafted);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    Path _frame = Path();

    _frame.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(
      Offset(-_size * 0.2, _size * 0.2),
      Offset(_size * 0.2, _size * 0.6)
    ),
    bottomLeft: Radius.circular(_size * 0.2),
    bottomRight: Radius.circular(_size * 0.2)));

    Path _element = Path();

    _element.moveTo(-_size * 0.2, _size * 0.2);
    _element.lineTo(_size * 0.2, _size * 0.2);

    _element.cubicTo(_size * 0.2, _size * 0.2, _size * 0.8, -_size * 0.8, 0.0, -_size * 0.8);

    _element.moveTo(-_size * 0.2, _size * 0.2);
    _element.cubicTo(-_size * 0.2, _size * 0.2, -_size * 0.8, -_size * 0.8, 0.0, -_size * 0.8);

    _p.strokeWidth = 0.4;
    _p.strokeCap = StrokeCap.round;
    canvas.drawPath(_element, _p..color = Colors.yellow);

    Path _bulbWires = Path();

    _bulbWires.moveTo(_size * 0.05, _size * 0.2);
    _bulbWires.lineTo(_size * 0.15, -_size * 0.4);

    _bulbWires.moveTo(-_size * 0.05, _size * 0.2);
    _bulbWires.lineTo(-_size * 0.15, -_size * 0.4);

    canvas.drawPath(_bulbWires, Paint()..color = Colors.black12..strokeWidth = 0.1..style = PaintingStyle.stroke);

    for(int i = 0; i < 6; i++){
      canvas.drawCircle(Offset(_size * 0.15 - (_size * 0.3 * (i / 5)), -_size * 0.4), 0.3, Paint()..color = Colors.black12..style = PaintingStyle.stroke..strokeWidth = 0.1);
    }

    canvas.drawPath(_frame, _p..color = Colors.grey.withOpacity(opacity));

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.2;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);

    canvas.restore();
  }
}