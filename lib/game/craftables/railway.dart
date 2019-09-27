part of factory_material;

class Railway extends FactoryMaterialModel{
  Railway.fromOffset(Offset o) : super(o.dx, o.dy, 8400.0, FactoryMaterialType.railway, state: FactoryMaterialState.crafted);

  Railway.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.railway, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();
    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(pi * 0.5);

    _p.color = Colors.brown.withOpacity(opacity);
    for(int i = 0; i < 3; i++){
      double _progress = i / 2;
      double _legSize = (_size - .5) * 1.5 * _progress - _size * 0.8;

      canvas.drawRect(Rect.fromPoints(Offset(_legSize, -_size * 0.8), Offset(_legSize + 2.4, _size * 0.8)), _p);
    }

    _p.color = Colors.grey.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.9, _size * 0.6), Offset(-_size * 0.9, _size * 0.4)), _p);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.9, -_size * 0.6), Offset(-_size * 0.9, -_size * 0.4)), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.iron): 10,
      FactoryRecipeMaterialType(FactoryMaterialType.iron, state: FactoryMaterialState.plate): 10,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Railway.custom(
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