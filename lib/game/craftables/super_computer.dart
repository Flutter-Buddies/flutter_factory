part of factory_material;

class SuperComputer extends FactoryMaterialModel {
  SuperComputer.fromOffset(Offset o)
      : super(o.dx, o.dy, 550000.0, FactoryMaterialType.superComputer, state: FactoryMaterialState.crafted);

  SuperComputer.custom(
      {double x,
      double y,
      double value,
      double size = 8.0,
      FactoryMaterialState state = FactoryMaterialState.crafted,
      double rotation,
      double offsetX,
      double offsetY})
      : super.custom(
            x: x,
            y: y,
            value: value,
            type: FactoryMaterialType.superComputer,
            size: size,
            state: state,
            rotation: rotation,
            offsetX: offsetX,
            offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}) {
    final Paint _p = Paint();
    final double _size = size * 0.7;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRect(Rect.fromPoints(
      Offset(_size, _size * 0.8),
      Offset(-_size, -_size * 0.8),
    ));

    final Path _screen = Path();

    _screen.addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0.0, -_size * 0.05), height: _size * 1.3, width: _size * 1.8),
        Radius.circular(_size * 0.1)));

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    _p.color = Colors.grey.shade900.withOpacity(opacity);
    canvas.drawPath(_screen, _p);

    canvas.drawCircle(Offset(_size * 0.9, _size * 0.7), _size * 0.04, _p..color = Colors.green);

    final Path _stand = Path();

    _stand.addArc(
        Rect.fromPoints(
          Offset(_size * 0.5, _size * 0.7),
          Offset(-_size * 0.5, _size * 1.5),
        ),
        0,
        -pi);

    canvas.drawPath(_stand, _p..color = Colors.black.withOpacity(opacity));

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.computer): 30,
      FactoryRecipeMaterialType(FactoryMaterialType.serverRack): 10,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return SuperComputer.custom(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      value: value ?? this.value,
      state: state,
      rotation: rotation,
      offsetX: offsetX,
      offsetY: offsetY,
    );
  }
}
