part of factory_material;

class Radio extends FactoryMaterialModel{
  Radio.fromOffset(Offset o) : super(o.dx, o.dy, 1500.0, FactoryMaterialType.radio, state: FactoryMaterialState.crafted);

  Radio.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.radio, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.5;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRect(Rect.fromPoints(
      Offset(_size, _size * 0.6),
      Offset(-_size, -_size * 0.6),
    ));

    _p.color = Colors.grey.shade800.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);

    canvas.drawRect(Rect.fromCenter(
      center: Offset(
        _size * 0.7,
        _size * 0.6
      ),
      width: _size * 0.4,
      height: _size * 0.1
    ), _p);

    canvas.drawRect(Rect.fromCenter(
      center: Offset(
        -_size * 0.7,
        _size * 0.6
      ),
      width: _size * 0.4,
      height: _size * 0.1
    ), _p);

    _p.color = Colors.grey.shade600.withOpacity(opacity);

    canvas.drawCircle(Offset(
      _size * 0.6, -_size * 0.2
    ), _size * 0.25, _p);

    canvas.drawCircle(Offset(
      _size * 0.6, _size * 0.3
    ), _size * 0.1, _p);

    canvas.drawCircle(Offset(
      -_size * 0.6, _size * 0.3
    ), _size * 0.1, _p);

    canvas.drawCircle(Offset(
      -_size * 0.6, -_size * 0.2
    ), _size * 0.25, _p);

    _p.color = Colors.blueGrey;
    canvas.drawRect(Rect.fromCenter(
      center: Offset(0.0, -_size * 0.2),
      width: _size * 0.45,
      height: _size * 0.3
    ), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.antenna): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.battery): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Radio.custom(
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