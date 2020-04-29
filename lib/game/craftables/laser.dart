part of factory_material;

class Laser extends FactoryMaterialModel {
  Laser.fromOffset(Offset o)
      : super(o.dx, o.dy, 32000.0, FactoryMaterialType.laser, state: FactoryMaterialState.crafted);

  Laser.custom(
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
            type: FactoryMaterialType.laser,
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
      Offset(_size * 0.5, _size * 0.2),
      Offset(-_size * 0.5, -_size * 0.2),
    ));

    _frame.addRect(Rect.fromPoints(
      Offset(-_size * 0.55, _size * 0.1),
      Offset(-_size * 0.5, -_size * 0.1),
    ));

    _p.color = Colors.grey.shade800.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);

    _p.style = PaintingStyle.stroke;
    _p.strokeWidth = 0.2;
    _p.shader = LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: const <double>[0.6, 1.0],
            colors: <Color>[Colors.green, Colors.transparent])
        .createShader(Rect.fromPoints(Offset(-_size * 0.55, 0.0), Offset(-_size, 0.0)));

    canvas.drawLine(Offset(-_size * 0.55, 0.0), Offset(-_size, 0.0), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.battery): 6,
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 6,
      FactoryRecipeMaterialType(FactoryMaterialType.diamond, state: FactoryMaterialState.plate): 10,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Laser.custom(
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
