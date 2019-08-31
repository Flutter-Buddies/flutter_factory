part of factory_material;

class Copper extends FactoryMaterialModel{
  Copper.fromOffset(Offset o) : super(o.dx, o.dy, 50.0, FactoryMaterialType.copper);

  Copper.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.raw, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.copper, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value}) {
    return Copper.custom(
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