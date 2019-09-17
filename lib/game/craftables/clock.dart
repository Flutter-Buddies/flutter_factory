part of factory_material;

class Clock extends FactoryMaterialModel{
  Clock.fromOffset(Offset o) : super(o.dx, o.dy, 540.0, FactoryMaterialType.clock, state: FactoryMaterialState.crafted);

  Clock.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.clock, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.4;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addOval(Rect.fromPoints(
      Offset(_size * 0.8, _size * 0.8),
      Offset(-_size * 0.8, -_size * 0.8),
    ));

    final Path _clockHands = Path();

    _clockHands.moveTo(0.0, 0.0);
    _clockHands.lineTo(_size * 0.3, -_size * 0.3);

    _clockHands.moveTo(0.0, 0.0);
    _clockHands.lineTo(0.0, -_size * 0.6);

    canvas.drawPath(_frame, _p..color = Colors.grey.withOpacity(opacity));

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);
    canvas.drawPath(_clockHands, _p..strokeWidth = .4);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.iron): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.gold): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.copper, state: FactoryMaterialState.gear): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Clock.custom(
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