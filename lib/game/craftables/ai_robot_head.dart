part of factory_material;

class AiRobotHead extends FactoryMaterialModel{
  AiRobotHead.fromOffset(Offset o) : super(o.dx, o.dy, 5000000.0, FactoryMaterialType.robotHead, state: FactoryMaterialState.crafted);

  AiRobotHead.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.robotHead, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.5;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.moveTo(-_size * 0.4, -_size * 0.4);

    _frame.addRect(Rect.fromPoints(
      Offset(_size * 0.5, _size * 0.6),
      Offset(-_size * 0.5, -_size * 0.2),
    ));

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
      FactoryRecipeMaterialType(FactoryMaterialType.aiProcessor): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 200,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return AiRobotHead.custom(
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