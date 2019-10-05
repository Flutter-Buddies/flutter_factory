part of factory_material;

class AiRobot extends FactoryMaterialModel{
  AiRobot.fromOffset(Offset o) : super(o.dx, o.dy, 15000000.0, FactoryMaterialType.robot, state: FactoryMaterialState.crafted);

  AiRobot.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.robot, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size;

    canvas.save();
    canvas.translate(offset.dx, offset.dy - _size * 0.5);
    FactoryMaterialModel.getFromType(FactoryMaterialType.robotHead)..size = _size..drawMaterial(offset, canvas, progress);
    canvas.restore();

    canvas.save();
    canvas.translate(offset.dx, offset.dy + _size * 0.5);
    FactoryMaterialModel.getFromType(FactoryMaterialType.robotBody)..size = _size..drawMaterial(offset, canvas, progress);
    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.robotHead): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.robotBody): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return AiRobot.custom(
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