part of factory_material;

class WaterHeater extends FactoryMaterialModel {
  WaterHeater.fromOffset(Offset o)
      : super(o.dx, o.dy, 13000.0, FactoryMaterialType.waterHeater, state: FactoryMaterialState.crafted);

  WaterHeater.custom(
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
            type: FactoryMaterialType.waterHeater,
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

    _frame.addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, height: _size * 1.6, width: _size * 1.2), Radius.circular(_size * 0.1)));

    _frame.addRect(Rect.fromPoints(Offset(_size * 0.25, _size), Offset(-_size * 0.25, _size * 0.8)));

    _p.color = Colors.grey.shade800.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    _p.style = PaintingStyle.stroke;
    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.1;
    canvas.drawPath(_frame, _p);

    _p.color = Colors.green;
    _p.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(_size * 0.15, _size * 0.86), _size * 0.02, _p);
    _p.color = Colors.white;
    canvas.drawCircle(Offset(_size * 0.05, _size * 0.9), _size * 0.05, _p);

    _p.color = Colors.red;
    _p.strokeWidth = 0.05;
    canvas.drawLine(Offset(_size * 0.05, _size * 0.95), Offset(_size * 0.05, _size * 0.9), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.heaterPlate): 5,
      FactoryRecipeMaterialType(FactoryMaterialType.diamond, state: FactoryMaterialState.plate): 5,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium, state: FactoryMaterialState.plate): 5,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return WaterHeater.custom(
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
