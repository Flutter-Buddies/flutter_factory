part of factory_material;

class CoolerPlate extends FactoryMaterialModel{
  CoolerPlate.fromOffset(Offset o) : super(o.dx, o.dy, 360.0, FactoryMaterialType.coolerPlate, state: FactoryMaterialState.crafted);

  CoolerPlate.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.coolerPlate, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.6;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    Path _frame = Path();

    _frame.addRRect(RRect.fromRectAndRadius(Rect.fromPoints(
      Offset(-_size * 0.9, -_size * 0.8),
      Offset(_size * 0.9, _size * 0.6)
    ), Radius.circular(_size * 0.2)));

    Path _element = Path();

    _element.addPolygon(<Offset>[
      Offset(-_size * 0.7, -_size * 0.6),
      Offset(-_size * 0.5, -_size * 0.4),
      Offset(-_size * 0.3, -_size * 0.6),
      Offset(-_size * 0.1, -_size * 0.4),
      Offset(_size * 0.1, -_size * 0.6),
      Offset(_size * 0.3, -_size * 0.4),
      Offset(_size * 0.5, -_size * 0.6),
      Offset(_size * 0.7, -_size * 0.4),
    ], false);

    _element.addPolygon(<Offset>[
      Offset(-_size * 0.7, -_size * 0.2),
      Offset(-_size * 0.5, 0.0),
      Offset(-_size * 0.3, -_size * 0.2),
      Offset(-_size * 0.1, 0.0),
      Offset(_size * 0.1, -_size * 0.2),
      Offset(_size * 0.3, 0.0),
      Offset(_size * 0.5, -_size * 0.2),
      Offset(_size * 0.7, 0.0),
    ], false);


    _element.addPolygon(<Offset>[
      Offset(-_size * 0.7, _size * 0.2),
      Offset(-_size * 0.5, _size * 0.4),
      Offset(-_size * 0.3, _size * 0.2),
      Offset(-_size * 0.1, _size * 0.4),
      Offset(_size * 0.1, _size * 0.2),
      Offset(_size * 0.3, _size * 0.4),
      Offset(_size * 0.5, _size * 0.2),
      Offset(_size * 0.7, _size * 0.4),
    ], false);

    _p.color = Colors.grey.withOpacity(opacity);
    _p.strokeWidth = 0.6;
    _p.strokeCap = StrokeCap.round;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    canvas.drawPath(_element, _p..color = Colors.blue..style = PaintingStyle.stroke);

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.2;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.diamond): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.gold): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.gold, state: FactoryMaterialState.spring): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return CoolerPlate.custom(
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