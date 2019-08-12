import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Gold extends FactoryMaterial{
  Gold.fromOffset(Offset o) : super(o.dx, o.dy, 50.0, FactoryMaterialType.gold);

  Gold.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.raw, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.gold, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  FactoryMaterial copyWith({double x, double y, double size, double value}) {
    return Gold.custom(
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