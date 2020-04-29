part of factory_material;

class Tv extends FactoryMaterialModel {
  Tv.fromOffset(Offset o) : super(o.dx, o.dy, 7100.0, FactoryMaterialType.tv, state: FactoryMaterialState.crafted);

  Tv.custom(
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
            type: FactoryMaterialType.tv,
            size: size,
            state: state,
            rotation: rotation,
            offsetX: offsetX,
            offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}) {
    final Paint _p = Paint();
    final double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRect(Rect.fromPoints(
      Offset(_size, _size * 0.8),
      Offset(-_size, -_size * 0.8),
    ));

    final Path _screen = Path();

    _screen.addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0.0, -_size * 0.1), height: _size * 1.2, width: _size * 1.6),
        Radius.circular(_size * 0.1)));

    _p.color = Colors.brown.shade800.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    _p.color = Colors.grey.shade700.withOpacity(opacity);
    canvas.drawPath(_screen, _p);

    canvas.drawCircle(Offset(_size * 0.75, _size * 0.65), _size * 0.05, _p..color = Colors.green);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.powerSupply): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 4,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Tv.custom(
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
