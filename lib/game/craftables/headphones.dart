part of factory_material;

class Headphones extends FactoryMaterialModel{
  Headphones.fromOffset(Offset o) : super(o.dx, o.dy, 900.0, FactoryMaterialType.headphones, state: FactoryMaterialState.crafted);

  Headphones.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.headphones, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.5;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addArc(Rect.fromPoints(
      Offset(_size * 0.8, _size * 0.8),
      Offset(-_size * 0.8, -_size * 0.8),
    ), 0.0, -pi);

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);

    _p.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(
      center: Offset(
        _size * 0.7,
        _size * 0.3
      ),
      width: _size * 0.4,
      height: _size * 0.8
    ), _p);

    canvas.drawRect(Rect.fromCenter(
      center: Offset(
        -_size * 0.7,
        _size * 0.3
      ),
      width: _size * 0.4,
      height: _size * 0.8
    ), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.gold, state: FactoryMaterialState.spring): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.diamond, state: FactoryMaterialState.spring): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Headphones.custom(
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