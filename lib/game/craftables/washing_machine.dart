part of factory_material;

class WashingMachine extends FactoryMaterialModel{
  WashingMachine.fromOffset(Offset o) : super(o.dx, o.dy, 900.0, FactoryMaterialType.washingMachine, state: FactoryMaterialState.crafted);

  WashingMachine.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.washingMachine, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.7;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRRect(RRect.fromRectAndRadius(Rect.fromPoints(
      Offset(_size * 0.8, _size * 1.0),
      Offset(-_size * 0.8, -_size * 0.8),
    ), Radius.circular(_size * 0.05)));

    canvas.drawPath(_frame, _p..color = Colors.white.withOpacity(opacity));

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.1;

    canvas.drawCircle(Offset.zero, _size * 0.6, _p..color = Colors.black.withOpacity(opacity)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset.zero, _size * 0.5, _p..color = Colors.grey.shade500.withOpacity(opacity)..style = PaintingStyle.fill);

    _p.color = Colors.black.withOpacity(opacity);
    _p.style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromPoints(Offset(_size * 0.75, -_size * 0.75), Offset(_size * 0.4, -_size * 0.55)), Radius.circular(_size * 0.05)),
      _p
    );

    canvas.drawLine(Offset(_size * 0.8, _size * 0.7), Offset(-_size * 0.8, _size * 0.7), _p);

    _p.strokeWidth = 0.2;
    canvas.drawPath(_frame, _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.engine): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.copper): 2,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return WashingMachine.custom(
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