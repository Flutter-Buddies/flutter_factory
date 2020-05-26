part of factory_material;

class Computer extends FactoryMaterialModel {
  Computer.fromOffset(Offset o)
      : super(o.dx, o.dy, 11000.0, FactoryMaterialType.computer, state: FactoryMaterialState.crafted);

  Computer.custom(
      {double x,
      double y,
      double value,
      double size = 8.0,
      FactoryMaterialState state = FactoryMaterialState.crafted,
      double rotation,
      double offsetX,
      double offsetY})
      : super.custom(
            x: x,
            y: y,
            value: value,
            type: FactoryMaterialType.computer,
            size: size,
            state: state,
            rotation: rotation,
            offsetX: offsetX,
            offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}) {
    Paint _p = Paint();

    double _size = size * 0.7;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRect(Rect.fromPoints(
      Offset(_size, _size * 0.8),
      Offset(-_size, -_size * 0.8),
    ));

    final Path _screen = Path();

    _screen.addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0.0, -_size * 0.05), height: _size * 1.3, width: _size * 1.8),
        Radius.circular(_size * 0.1)));

    _p.color = Colors.grey.shade400.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    _p.color = Colors.grey.shade900.withOpacity(opacity);
    canvas.drawPath(_screen, _p);

    canvas.drawCircle(Offset(_size * 0.9, _size * 0.7), _size * 0.04, _p..color = Colors.green);
    canvas.drawCircle(Offset(_size * 0.7, _size * 0.7), _size * 0.02, _p..color = Colors.grey);
    canvas.drawCircle(Offset(_size * 0.8, _size * 0.7), _size * 0.02, _p..color = Colors.grey);

    final Path _stand = Path();

    _stand.addArc(
        Rect.fromPoints(
          Offset(_size * 0.5, _size * 0.7),
          Offset(-_size * 0.5, _size * 1.5),
        ),
        0,
        -pi);

    canvas.drawPath(_stand, _p..color = Colors.grey.shade400.withOpacity(opacity));

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 6,
      FactoryRecipeMaterialType(FactoryMaterialType.processor): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.powerSupply): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Computer.custom(
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
