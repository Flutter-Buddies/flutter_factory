part of factory_material;

class Fridge extends FactoryMaterialModel{
  Fridge.fromOffset(Offset o) : super(o.dx, o.dy, 7400.0, FactoryMaterialType.fridge, state: FactoryMaterialState.crafted);

  Fridge.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.fridge, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();
    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(pi * 0.5);

    _p.color = Colors.black.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.94, _size * 0.64), Offset(-_size * 0.94, -_size * 0.64)), _p);
    _p.color = Colors.white.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.9, _size * 0.6), Offset(-_size * 0.9, -_size * 0.6)), _p);
    _p.color = Colors.grey.shade700.withOpacity(opacity);

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromPoints(
        Offset(_size * 0.35, _size * 0.55),
        Offset(_size * 0.70, _size * 0.5),
      ), Radius.circular(2.0)
    ), _p);

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromPoints(
        Offset(-_size * 0.55, _size * 0.55),
        Offset(_size * 0.05, _size * 0.5),
      ), Radius.circular(2.0)
    ), _p);

    canvas.drawLine(Offset(_size * 0.2, -_size * 0.6), Offset(_size * 0.2, _size * 0.6), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.coolerPlate): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.powerSupply): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 6,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Fridge.custom(
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