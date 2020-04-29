part of factory_material;

class Processor extends FactoryMaterialModel {
  Processor.fromOffset(Offset o)
      : super(o.dx, o.dy, 900.0, FactoryMaterialType.processor, state: FactoryMaterialState.crafted);

  Processor.custom(
      {double x,
      double y,
      double value,
      double size = 8.0,
      FactoryMaterialState state = FactoryMaterialState.crafted,
      double rotation,
      double offsetX,
      double offsetY})
      : super.custom(
            x: x,
            y: y,
            value: value,
            type: FactoryMaterialType.processor,
            size: size,
            state: state,
            rotation: rotation,
            offsetX: offsetX,
            offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}) {
    final Paint _p = Paint();
    final double _size = size * 0.4;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _p.color = Colors.black.withOpacity(opacity);
    for (int i = 0; i < 4; i++) {
      final double _progress = i / 3;
      final double _legSize = (_size - .5) * 1.5 * _progress - _size * 0.75;

      canvas.drawRect(Rect.fromPoints(Offset(_legSize, _size), Offset(_legSize + 0.5, _size * 0.75)), _p);
      canvas.drawRect(Rect.fromPoints(Offset(_legSize, -_size), Offset(_legSize + 0.5, -_size * 0.75)), _p);

      canvas.drawRect(Rect.fromPoints(Offset(_size, _legSize), Offset(_size * 0.75, _legSize + 0.5)), _p);
      canvas.drawRect(Rect.fromPoints(Offset(-_size, _legSize), Offset(-_size * 0.75, _legSize + 0.5)), _p);
    }

    _p.color = Colors.black.withOpacity(opacity);
    canvas.drawRect(
        Rect.fromPoints(Offset(_size * 0.75 + .2, _size * 0.75 - .2), Offset(-_size * 0.75 - .2, -_size * 0.75 - .2)),
        _p);

    _p.color = Colors.white.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.75, _size * 0.75), Offset(-_size * 0.75, -_size * 0.75)), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 2
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Processor.custom(
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
