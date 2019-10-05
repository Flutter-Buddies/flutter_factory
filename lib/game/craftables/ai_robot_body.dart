part of factory_material;

class AiRobotBody extends FactoryMaterialModel{
  AiRobotBody.fromOffset(Offset o) : super(o.dx, o.dy, 2800000.0, FactoryMaterialType.robotBody, state: FactoryMaterialState.crafted);

  AiRobotBody.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.robotBody, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.6;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.moveTo(-_size * 0.4, -_size * 0.4);

    _frame.addRect(Rect.fromPoints(
      Offset(_size * 0.6, _size * 0.3),
      Offset(-_size * 0.6, -_size),
    ));

    _frame.addRect(Rect.fromPoints(
      Offset(-_size * 0.65, _size * 0.3),
      Offset(-_size * 0.9, -_size * 0.85),
    ));

    _frame.addRect(Rect.fromPoints(
      Offset(_size * 0.65, _size * 0.3),
      Offset(_size * 0.9, -_size * 0.85),
    ));

    _frame.addRect(Rect.fromPoints(
      Offset(-_size * 0.1, _size * 0.4),
      Offset(-_size * 0.5, _size),
    ));

    _frame.addRect(Rect.fromPoints(
      Offset(_size * 0.1, _size * 0.4),
      Offset(_size * 0.5, _size),
    ));

    canvas.drawPath(_frame, _p..color = Colors.grey.withOpacity(opacity));

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.electricGenerator): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.electricEngine): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 400,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return AiRobotBody.custom(
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