part of factory_material;

class Aluminium extends FactoryMaterialModel {
  Aluminium.fromOffset(Offset o) : super(o.dx, o.dy, 50.0, FactoryMaterialType.aluminium);

  Aluminium.custom(
      {double x,
      double y,
      double value,
      double size = 8.0,
      FactoryMaterialState state = FactoryMaterialState.raw,
      double rotation,
      double offsetX,
      double offsetY})
      : super.custom(
            x: x,
            y: y,
            value: value,
            type: FactoryMaterialType.aluminium,
            size: size,
            state: state,
            rotation: rotation,
            offsetX: offsetX,
            offsetY: offsetY);

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value}) {
    return Aluminium.custom(
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
