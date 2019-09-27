part of factory_material;

class Microwave extends FactoryMaterialModel{
  Microwave.fromOffset(Offset o) : super(o.dx, o.dy, 8070.0, FactoryMaterialType.microwave, state: FactoryMaterialState.crafted);

  Microwave.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.microwave, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRect(Rect.fromPoints(
      Offset(_size, _size * 0.6),
      Offset(-_size, -_size * 0.6),
    ));

    final Path _screen = Path();

    _screen.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-_size * 0.2, 0.0),
        height: _size * 1.0,
        width: _size * 1.4
      ), Radius.circular(_size * 0.01))
    );

    _p.color = Colors.white.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    _p.color = Colors.grey.shade700.withOpacity(opacity);
    canvas.drawPath(_screen, _p);

    canvas.drawCircle(Offset(_size * 0.85, _size * 0.45), _size * 0.1, _p..color = Colors.grey);

    canvas.drawRect(Rect.fromCenter(
      center: Offset(_size * 0.6, 0.0),
      height: _size * 0.8,
      width: _size * 0.1
    ), _p);


    canvas.drawRect(Rect.fromCenter(
      center: Offset(-_size * 0.12, 0.0),
      height: _size * 1.1,
      width: _size * 1.65
    ), _p..color = Colors.grey.shade600..strokeWidth = 0.1..style = PaintingStyle.stroke);

    canvas.drawRect(Rect.fromPoints(
      Offset(_size, _size * 0.6),
      Offset(-_size, -_size * 0.6),
    ), _p..color = Colors.black87..strokeWidth = 0.1..style = PaintingStyle.stroke);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.heaterPlate): 5,
      FactoryRecipeMaterialType(FactoryMaterialType.diamond, state: FactoryMaterialState.plate): 5,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 5,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Microwave.custom(
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