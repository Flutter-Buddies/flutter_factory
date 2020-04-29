part of factory_material;

class Speakers extends FactoryMaterialModel {
  Speakers.fromOffset(Offset o)
      : super(o.dx, o.dy, 1500.0, FactoryMaterialType.speakers, state: FactoryMaterialState.crafted);

  Speakers.custom(
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
            type: FactoryMaterialType.speakers,
            size: size,
            state: state,
            rotation: rotation,
            offsetX: offsetX,
            offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}) {
    final Paint _p = Paint();
    final double _size = size * 0.6;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _p.strokeWidth = 0.8;
    _p.color = Colors.grey.shade700.withOpacity(opacity);

    _p.style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromCenter(center: Offset.zero, height: _size, width: _size * 0.8), _p);
    _p.color = Colors.black.withOpacity(opacity);

    canvas.drawCircle(Offset(size * 0.1, _size * 0.3), _size * 0.1, _p);

    canvas.drawCircle(Offset(-size * 0.1, _size * 0.3), _size * 0.1, _p);

    canvas.drawCircle(Offset(0.0, -_size * 0.15), _size * 0.28, _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.diamond, state: FactoryMaterialState.spring): 4,
      FactoryRecipeMaterialType(FactoryMaterialType.gold, state: FactoryMaterialState.spring): 4,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Speakers.custom(
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
