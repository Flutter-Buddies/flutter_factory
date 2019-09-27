part of factory_material;

class Tablet extends FactoryMaterialModel{
  Tablet.fromOffset(Offset o) : super(o.dx, o.dy, 7600.0, FactoryMaterialType.tablet, state: FactoryMaterialState.crafted);

  Tablet.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.tablet, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0.0, 0.0),
        height: _size * 1.9,
        width: _size * 1.6
      ), Radius.circular(_size * 0.1))
    );

    final Path _screen = Path();

    _screen.addRect(Rect.fromCenter(
      center: Offset(0.0, -_size * 0.1),
      height: _size * 1.5,
      width: _size * 1.4
    )
    );

    _screen.addOval(Rect.fromCenter(
      center: Offset(0.0, _size * 0.8),
      height: _size * 0.2,
      width: _size * 0.2,
    ));

    _p.color = Colors.grey.shade800.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    _p.style = PaintingStyle.stroke;
    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.1;
    canvas.drawPath(_frame, _p);

    _p.style = PaintingStyle.fill;
    _p.color = Colors.black87.withOpacity(opacity);
    canvas.drawPath(_screen, _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.processor): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.battery): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 4,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Tablet.custom(
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