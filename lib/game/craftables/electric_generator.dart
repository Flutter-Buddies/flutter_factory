part of factory_material;

class ElectricGenerator extends FactoryMaterialModel{
  ElectricGenerator.fromOffset(Offset o) : super(o.dx, o.dy, 540.0, FactoryMaterialType.electricGenerator, state: FactoryMaterialState.crafted);

  ElectricGenerator.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.electricGenerator, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

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

    _p.color = Colors.blue.shade600.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);

    canvas.drawRect(Rect.fromPoints(
      Offset(_size, _size * 0.6),
      Offset(-_size, -_size * 0.6),
    ), _p..color = Colors.black87..strokeWidth = 0.1..style = PaintingStyle.stroke);


    _p.style = PaintingStyle.fill;
    _p.color = Colors.blue.shade900.withOpacity(opacity);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromPoints(
        Offset(_size * 0.8, -_size * 0.2),
        Offset(_size * 0.2, _size * 0.2)
      ), Radius.circular(_size * 0.1)
    ), _p);

    _p.style = PaintingStyle.stroke;
    _p.color = Colors.black.withOpacity(opacity);

    canvas.drawLine(
      Offset(_size * 0.8, _size * 0.1),
      Offset(_size * 0.2, _size * 0.1),
      _p
    );

    canvas.drawLine(
      Offset(_size * 0.8, 0.0),
      Offset(_size * 0.2, 0.0),
      _p
    );

    canvas.drawLine(
      Offset(_size * 0.8, -_size * 0.1),
      Offset(_size * 0.2, -_size * 0.1),
      _p
    );

    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromPoints(
        Offset(_size * 0.8, -_size * 0.2),
        Offset(_size * 0.2, _size * 0.2)
      ), Radius.circular(_size * 0.1)
    ), _p);

    canvas.drawCircle(Offset(-_size * 0.4, 0.0), _size * 0.4, _p);
    _p.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cos(progress * pi * 2) * -_size * 0.3 + -_size * 0.4, sin(progress * pi * 2) * _size * 0.3), _size * 0.05, _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.generator): 15,
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 40,
      FactoryRecipeMaterialType(FactoryMaterialType.battery): 50,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return ElectricGenerator.custom(
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