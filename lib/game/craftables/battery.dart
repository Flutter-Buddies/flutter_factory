part of factory_material;

class Battery extends FactoryMaterialModel{
  Battery.fromOffset(Offset o) : super(o.dx, o.dy, 900.0, FactoryMaterialType.battery, state: FactoryMaterialState.crafted);

  Battery.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.battery, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    final Paint _p = Paint();
    final double _size = size * 0.3;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _p.color = Colors.green.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.75, _size * 0.5), Offset(-_size * 0.9, -_size * 0.5)), _p);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.75, _size * 0.2), Offset(_size * 0.9, -_size * 0.2)), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium, state: FactoryMaterialState.fluid): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Battery.custom(
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