import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Processor extends FactoryMaterial{
  Processor.fromOffset(Offset o) : super(o.dx, o.dy, FactoryMaterialType.processor);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress){
    Paint _p = Paint();

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _p.color = Colors.red;
    for(int i = 0; i < 4; i++){
      double _progress = i / 3;
      double _size = (size - .5) * 1.5 * _progress - size * 0.75;

      canvas.drawRect(Rect.fromPoints(Offset(_size, size * 0.8), Offset(_size + 0.5, size * 0.5)), _p);
      canvas.drawRect(Rect.fromPoints(Offset(_size, -size * 0.8), Offset(_size + 0.5, -size * 0.5)), _p);
    }

    _p.color = Colors.black;
    canvas.drawRect(Rect.fromPoints(Offset(size * 0.75 + .2, size * 0.5 -.2), Offset(-size * 0.75 - .2, -size * 0.5 - .2)), _p);

    _p.color = Colors.orange;
    canvas.drawRect(Rect.fromPoints(Offset(size * 0.75, size * 0.5), Offset(-size * 0.75, -size * 0.5)), _p);

    canvas.restore();
  }
}