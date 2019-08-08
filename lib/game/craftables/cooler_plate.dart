import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class CoolerPlate extends FactoryMaterial{
  CoolerPlate.fromOffset(Offset o) : super(o.dx, o.dy, 200.0, FactoryMaterialType.coolerPlate, state: FactoryMaterialState.crafted);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    Path _frame = Path();

    _frame.addRRect(RRect.fromRectAndRadius(Rect.fromPoints(
      Offset(-_size * 0.9, -_size * 0.8),
      Offset(_size * 0.9, _size * 0.6)
    ), Radius.circular(_size * 0.2)));

    Path _element = Path();

    _element.addPolygon(<Offset>[
      Offset(-_size * 0.7, -_size * 0.6),
      Offset(-_size * 0.5, -_size * 0.4),
      Offset(-_size * 0.3, -_size * 0.6),
      Offset(-_size * 0.1, -_size * 0.4),
      Offset(_size * 0.1, -_size * 0.6),
      Offset(_size * 0.3, -_size * 0.4),
      Offset(_size * 0.5, -_size * 0.6),
      Offset(_size * 0.7, -_size * 0.4),
    ], false);

    _element.addPolygon(<Offset>[
      Offset(-_size * 0.7, -_size * 0.2),
      Offset(-_size * 0.5, 0.0),
      Offset(-_size * 0.3, -_size * 0.2),
      Offset(-_size * 0.1, 0.0),
      Offset(_size * 0.1, -_size * 0.2),
      Offset(_size * 0.3, 0.0),
      Offset(_size * 0.5, -_size * 0.2),
      Offset(_size * 0.7, 0.0),
    ], false);


    _element.addPolygon(<Offset>[
      Offset(-_size * 0.7, _size * 0.2),
      Offset(-_size * 0.5, _size * 0.4),
      Offset(-_size * 0.3, _size * 0.2),
      Offset(-_size * 0.1, _size * 0.4),
      Offset(_size * 0.1, _size * 0.2),
      Offset(_size * 0.3, _size * 0.4),
      Offset(_size * 0.5, _size * 0.2),
      Offset(_size * 0.7, _size * 0.4),
    ], false);

    _p.color = Colors.grey.withOpacity(opacity);
    _p.strokeWidth = 0.6;
    _p.strokeCap = StrokeCap.round;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    canvas.drawPath(_element, _p..color = Colors.blue..style = PaintingStyle.stroke);

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.2;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);

    canvas.restore();
  }
}