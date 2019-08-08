import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Railway extends FactoryMaterial{
  Railway.fromOffset(Offset o) : super(o.dx, o.dy, 120.0, FactoryMaterialType.railway, state: FactoryMaterialState.crafted);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();
    double _size = size * 0.4;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(pi * 0.5);

    _p.color = Colors.brown.withOpacity(opacity);
    for(int i = 0; i < 3; i++){
      double _progress = i / 2;
      double _legSize = (_size - .5) * 1.5 * _progress - _size * 0.8;

      canvas.drawRect(Rect.fromPoints(Offset(_legSize, -_size * 0.8), Offset(_legSize + 1.0, _size * 0.8)), _p);
    }

    _p.color = Colors.grey.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.9, _size * 0.6), Offset(-_size * 0.9, _size * 0.4)), _p);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.9, -_size * 0.6), Offset(-_size * 0.9, -_size * 0.4)), _p);

    canvas.restore();
  }
}