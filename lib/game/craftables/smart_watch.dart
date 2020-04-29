part of factory_material;

class SmartWatch extends FactoryMaterialModel {
  SmartWatch.fromOffset(Offset o)
      : super(o.dx, o.dy, 8400.0, FactoryMaterialType.smartWatch, state: FactoryMaterialState.crafted);

  SmartWatch.custom(
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
            type: FactoryMaterialType.smartWatch,
            size: size,
            state: state,
            rotation: rotation,
            offsetX: offsetX,
            offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}) {
    final Paint _p = Paint();
    final double _size = size * 0.5;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();
    final Path _bands = Path();

    _bands.addRRect(RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(_size * 0.3, _size * 0.8),
          Offset(-_size * 0.3, -_size * 0.8),
        ),
        Radius.circular(_size * 0.05)));

    canvas.drawPath(_bands, _p..color = Colors.white.withOpacity(opacity));

    _frame.addRRect(RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(_size * 0.4, _size * 0.4),
          Offset(-_size * 0.4, -_size * 0.4),
        ),
        Radius.circular(_size * 0.05)));

    canvas.drawPath(_frame, _p..color = Colors.white.withOpacity(opacity));
    canvas.drawPath(
        _frame,
        _p
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.04
          ..color = Colors.black.withOpacity(opacity));

    _p.style = PaintingStyle.fill;

    final Path _screen = Path();

    _screen.addRRect(RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(_size * 0.35, _size * 0.35),
          Offset(-_size * 0.35, -_size * 0.35),
        ),
        Radius.circular(_size * 0.05)));

    canvas.drawPath(_screen, _p..color = Colors.black.withOpacity(opacity));

    canvas.drawLine(Offset(_size * 0.3, _size * 0.6), Offset(-_size * 0.3, _size * 0.6), _p);
    canvas.drawLine(Offset(_size * 0.3, -_size * 0.6), Offset(-_size * 0.3, -_size * 0.6), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.iron, state: FactoryMaterialState.plate): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium, state: FactoryMaterialState.plate): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.processor): 2,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return SmartWatch.custom(
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
