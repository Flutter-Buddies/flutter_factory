part of factory_material;

class AirConditioner extends FactoryMaterialModel{
  AirConditioner.fromOffset(Offset o) : super(o.dx, o.dy, 900.0, FactoryMaterialType.airCondition, state: FactoryMaterialState.crafted);

  AirConditioner.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.raw, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.airCondition, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 1.0;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(
      Offset(_size * 0.8, _size * 0.8),
      Offset(-_size * 0.8, 0.0),
    ), topLeft: Radius.circular(_size * 0.4), topRight: Radius.circular(_size * 0.4)));

    canvas.drawPath(_frame, _p..color = Colors.white.withOpacity(opacity));

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.2;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);
    _p.strokeWidth = 0.1;

    canvas.drawLine(Offset(_size * 0.8, _size * 0.62), Offset(-_size * 0.8, _size * 0.62), _p);
    canvas.drawLine(Offset(_size * 0.8, _size * 0.68), Offset(-_size * 0.8, _size * 0.68), _p);
    canvas.drawLine(Offset(_size * 0.8, _size * 0.74), Offset(-_size * 0.8, _size * 0.74), _p);

    canvas.drawCircle(Offset(
      _size * 0.7, _size * 0.5
    ), 0.25, _p..color = Colors.green..style = PaintingStyle.fill);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.coolerPlate): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.gold): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return AirConditioner.custom(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      value: value ?? this.value,
      state: this.state,
      rotation: this.rotation,
      offsetX: this.offsetX,
      offsetY: this.offsetY,
    );
  }
}