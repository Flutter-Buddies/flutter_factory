part of factory_material;

class ServerRack extends FactoryMaterialModel{
  ServerRack.fromOffset(Offset o) : super(o.dx, o.dy, 11000.0, FactoryMaterialType.serverRack, state: FactoryMaterialState.crafted);

  ServerRack.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.raw, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.serverRack, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();
    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(pi * 0.5);

    _p.color = Colors.black.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.94, _size * 0.64), Offset(-_size * 0.94, -_size * 0.64)), _p);
    _p.color = Colors.grey.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.9, _size * 0.6), Offset(-_size * 0.9, -_size * 0.6)), _p);
    _p.color = Colors.grey.shade700.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.65, _size * 0.45), Offset(-_size * 0.75, -_size * 0.45)), _p);

    _p.color = Colors.grey.shade800.withOpacity(opacity);
    for(int i = 0; i < 3; i++){
      final double _progress = i / 2;
      final double _legSize = (_size - .5) * _progress - _size * 0.5;

      canvas.drawRect(Rect.fromPoints(Offset(_legSize, -_size * 0.45), Offset(_legSize + 0.4, _size * 0.45)), _p);
    }

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromPoints(
        Offset(_size * 0.15, _size * 0.55),
        Offset(-_size * 0.15, _size * 0.5),
      ), Radius.circular(2.0)
    ), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 10,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium, state: FactoryMaterialState.plate): 20,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return ServerRack.custom(
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