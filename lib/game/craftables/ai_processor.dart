part of factory_material;

class AiProcessor extends FactoryMaterialModel{
  AiProcessor.fromOffset(Offset o) : super(o.dx, o.dy, 2500000.0, FactoryMaterialType.aiProcessor, state: FactoryMaterialState.crafted);

  AiProcessor.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.aiProcessor, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();
    double _size = size * 0.4;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    _p.color = Colors.black.withOpacity(opacity);
    for(int i = 0; i < 4; i++){
      double _progress = i / 3;
      double _legSize = (_size - .5) * 1.5 * _progress - _size * 0.75;

      canvas.drawRect(Rect.fromPoints(Offset(_legSize, _size), Offset(_legSize + 0.5, _size * 0.75)), _p);
      canvas.drawRect(Rect.fromPoints(Offset(_legSize, -_size), Offset(_legSize + 0.5, -_size * 0.75)), _p);

      canvas.drawRect(Rect.fromPoints(Offset(_size, _legSize), Offset(_size * 0.75, _legSize + 0.5)), _p);
      canvas.drawRect(Rect.fromPoints(Offset(-_size, _legSize), Offset(-_size * 0.75, _legSize + 0.5)), _p);
    }

    _p.color = Colors.black.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.75 + .2, _size * 0.75 -.2), Offset(-_size * 0.75 - .2, -_size * 0.75 - .2)), _p);

    _p.color = Colors.blue.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.75, _size * 0.75), Offset(-_size * 0.75, -_size * 0.75)), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.superComputer): 4,
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 40,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return AiProcessor.custom(
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