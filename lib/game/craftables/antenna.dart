part of factory_material;

class Antenna extends FactoryMaterialModel {
  Antenna.fromOffset(Offset o)
      : super(o.dx, o.dy, 540.0, FactoryMaterialType.antenna, state: FactoryMaterialState.crafted);

  Antenna.custom(
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
            type: FactoryMaterialType.antenna,
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

    _frame.moveTo(-_size * 0.4, -_size * 0.4);

    _frame.addArc(
        Rect.fromPoints(
          Offset(_size * 0.3, _size * 0.8),
          Offset(-_size * 0.3, _size * 0.3),
        ),
        0,
        -pi);

    final Path _clockHands = Path();

    _clockHands.moveTo(0.0, _size * 0.4);
    _clockHands.lineTo(_size * 0.6, -_size * 0.8);

    _clockHands.moveTo(0.0, _size * 0.4);
    _clockHands.lineTo(-_size * 0.6, -_size * 0.8);

    canvas.drawPath(_frame, _p..color = Colors.grey.withOpacity(opacity));

    _p.color = Colors.grey.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);
    canvas.drawPath(_clockHands, _p..strokeWidth = .4);

    _p.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-_size * 0.6, -_size * 0.8), 0.8, _p);
    canvas.drawCircle(Offset(_size * 0.6, -_size * 0.8), 0.8, _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.diamond, state: FactoryMaterialState.spring): 4,
      FactoryRecipeMaterialType(FactoryMaterialType.iron): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Antenna.custom(
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
