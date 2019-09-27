part of factory_material;

class ComputerChip extends FactoryMaterialModel{
  ComputerChip.fromOffset(Offset o) : super(o.dx, o.dy, 360.0, FactoryMaterialType.computerChip, state: FactoryMaterialState.crafted);

  ComputerChip.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.computerChip, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();
    double _size = size * 0.3;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _p.color = Colors.red.withOpacity(opacity);
    for(int i = 0; i < 4; i++){
      double _progress = i / 3;
      double _legSize = (_size - .5) * 1.5 * _progress - _size * 0.75;

      canvas.drawRect(Rect.fromPoints(Offset(_legSize, _size * 0.8), Offset(_legSize + 0.5, _size * 0.5)), _p);
      canvas.drawRect(Rect.fromPoints(Offset(_legSize, -_size * 0.8), Offset(_legSize + 0.5, -_size * 0.5)), _p);
    }

    _p.color = Colors.black.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.75 + .2, _size * 0.5 -.2), Offset(-_size * 0.75 - .2, -_size * 0.5 - .2)), _p);

    _p.color = Colors.orange.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.75, _size * 0.5), Offset(-_size * 0.75, -_size * 0.5)), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.copper, state: FactoryMaterialState.spring): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.gold): 1
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return ComputerChip.custom(
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