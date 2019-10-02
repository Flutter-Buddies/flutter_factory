part of factory_material;

class Oven extends FactoryMaterialModel{
  Oven.fromOffset(Offset o) : super(o.dx, o.dy, 27000.0, FactoryMaterialType.oven, state: FactoryMaterialState.crafted);

  Oven.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.oven, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRect(Rect.fromPoints(
      Offset(_size, _size * 0.8),
      Offset(-_size, -_size * 0.8),
    ));

    final Path _screen = Path();

    _screen.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0.0, _size * 0.1),
        height: _size * 1.0,
        width: _size * 1.4
      ), Radius.circular(_size * 0.1))
    );

    _p.color = Colors.grey.shade200.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    _p.color = Colors.grey.shade700.withOpacity(opacity);
    canvas.drawPath(_screen, _p);

    _p.color = Colors.black;
    _p.style = PaintingStyle.stroke;
    _p.strokeWidth = 0.1;

    canvas.drawRect(Rect.fromCenter(
      center: Offset(0.0, _size * 0.05),
      height: _size * 1.2,
      width: _size * 1.6
    ), _p);

    _p.strokeWidth = 0.6;

    canvas.drawLine(Offset(-_size * 0.3, -_size * 0.5), Offset(_size * 0.3, -_size * 0.5), _p);

    _p.style = PaintingStyle.fill;

    canvas.drawCircle(Offset(_size * 0.75, -_size * 0.65), _size * 0.05, _p..color = Colors.green);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.heaterPlate): 10,
      FactoryRecipeMaterialType(FactoryMaterialType.iron, state: FactoryMaterialState.plate): 10,
      FactoryRecipeMaterialType(FactoryMaterialType.iron): 10,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Oven.custom(
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