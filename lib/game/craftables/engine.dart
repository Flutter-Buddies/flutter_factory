part of factory_material;

class Engine extends FactoryMaterialModel{
  Engine.fromOffset(Offset o) : super(o.dx, o.dy, 360.0, FactoryMaterialType.engine, state: FactoryMaterialState.crafted);

  Engine.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.engine, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.6;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(-pi / 2);

    Path _engineDetails = Path();

    _engineDetails.moveTo(_size * 0.4, -_size);
    _engineDetails.lineTo(-_size * 0.4, -_size);

    _engineDetails.moveTo(0.0, -_size);
    _engineDetails.lineTo(0.0, -_size * 0.8);

    _engineDetails.moveTo(_size * 0.5, -_size * 0.8);

    _engineDetails.moveTo(_size * 0.7, 0.0);
    _engineDetails.lineTo(_size * 0.9, 0.0);
    _engineDetails.moveTo(_size * 0.9, _size * 0.3);
    _engineDetails.lineTo(_size * 0.9, -_size * 0.3);

    Path _engine = Path();

    _engine.addPolygon(<Offset>[
      Offset(-_size * 0.4, -_size * 0.8),
      Offset(-_size * 0.4, -_size * 0.4),
      Offset(-_size * 0.7, -_size * 0.2),
      Offset(-_size * 0.7, _size * 0.5),
      Offset(-_size * 0.4, _size * 0.5),
      Offset(-_size * 0.4, _size * 0.6),
      Offset(-_size * 0.6, _size * 0.6),
      Offset(-_size * 0.6, _size * 0.7),
      Offset(-_size * 0.4, _size * 0.9),
      Offset(_size * 0.4, _size * 0.9),
      Offset(_size * 0.6, _size * 0.7),
      Offset(_size * 0.6, _size * 0.6),
      Offset(_size * 0.4, _size * 0.6),
      Offset(_size * 0.4, _size * 0.5),
      Offset(_size * 0.5, _size * 0.5),
      Offset(_size * 0.5, _size * 0.3),
      Offset(_size * 0.7, _size * 0.3),
      Offset(_size * 0.7, -_size * 0.4),
      Offset(_size * 0.4, -_size * 0.4),
      Offset(_size * 0.4, -_size * 0.8),
    ], true);


    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 1.6;
    _p.strokeCap = StrokeCap.round;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_engineDetails, _p);
    _p.strokeWidth = 0.5;
    canvas.drawPath(_engine, _p);

    _p.color = Colors.white.withOpacity(opacity);
    _p.strokeWidth = 1.0;
    _p.strokeCap = StrokeCap.round;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_engineDetails, _p);
    canvas.drawPath(_engine, _p..style = PaintingStyle.fill);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.iron, state: FactoryMaterialState.gear): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.gold, state: FactoryMaterialState.gear): 1
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Engine.custom(
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