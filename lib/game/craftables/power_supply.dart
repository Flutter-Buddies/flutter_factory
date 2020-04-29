part of factory_material;

class PowerSupply extends FactoryMaterialModel {
  PowerSupply.fromOffset(Offset o)
      : super(o.dx, o.dy, 1500.0, FactoryMaterialType.powerSupply, state: FactoryMaterialState.crafted);

  PowerSupply.custom(
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
            type: FactoryMaterialType.powerSupply,
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

    _frame.addRect(Rect.fromPoints(
      Offset(_size, _size * 0.6),
      Offset(-_size, -_size * 0.6),
    ));

    _p.color = Colors.grey.shade800.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);

    canvas.drawRect(
        Rect.fromCenter(center: Offset(_size * 0.7, _size * 0.6), width: _size * 0.4, height: _size * 0.1), _p);

    canvas.drawRect(
        Rect.fromCenter(center: Offset(-_size * 0.7, _size * 0.6), width: _size * 0.4, height: _size * 0.1), _p);

    _p.color = Colors.grey.shade600.withOpacity(opacity);
    canvas.drawCircle(Offset(_size * 0.4, 0.0), _size * 0.4, _p);

    final Path _lightning = Path();

    _lightning.moveTo(-_size * 0.5, -_size * 0.3);
    _lightning.lineTo(-_size * 0.6, _size * 0.1);
    _lightning.lineTo(-_size * 0.4, -_size * 0.1);
    _lightning.lineTo(-_size * 0.5, _size * 0.3);

    canvas.drawPath(
        _lightning,
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.2
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.copper, state: FactoryMaterialState.spring): 3,
      FactoryRecipeMaterialType(FactoryMaterialType.iron, state: FactoryMaterialState.spring): 3,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return PowerSupply.custom(
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
