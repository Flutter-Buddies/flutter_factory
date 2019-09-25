part of factory_material;

class ElectricBoard extends FactoryMaterialModel{
  ElectricBoard.fromOffset(Offset o) : super(o.dx, o.dy, 27000.0, FactoryMaterialType.electricBoard, state: FactoryMaterialState.crafted);

  ElectricBoard.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.electricBoard, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.5;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRect(Rect.fromPoints(
      Offset(_size, _size * 0.8),
      Offset(-_size, -_size * 0.8),
    ));

    _p.color = Colors.green.shade800.withOpacity(opacity);
    _p.strokeWidth = 0.8;
    _p.style = PaintingStyle.fill;
    canvas.drawPath(_frame, _p);
    _p.color = Colors.yellow.shade700.withOpacity(opacity);
    _p.strokeWidth = 0.3;
    _p.strokeJoin = StrokeJoin.round;
    _p.strokeCap = StrokeCap.round;


    canvas.drawLine(Offset(_size * 0.2, -_size * 0.6), Offset(_size, -_size * 0.6), _p);
    canvas.drawLine(Offset(_size * 0.2, -_size * 0.6), Offset(-_size * 0.2, 0.0), _p);

    canvas.drawLine(Offset(_size * 0.2, -_size * 0.4), Offset(_size, -_size * 0.4), _p);
    canvas.drawLine(Offset(_size * 0.2, -_size * 0.4), Offset(-_size * 0.2, 0.0), _p);

    canvas.drawLine(Offset(_size * 0.2, -_size * 0.2), Offset(_size, -_size * 0.2), _p);
    canvas.drawLine(Offset(_size * 0.2, -_size * 0.2), Offset(-_size * 0.2, 0.0), _p);

    canvas.drawLine(Offset(_size * 0.2, 0.0), Offset(_size, 0.0), _p);
    canvas.drawLine(Offset(_size * 0.2, 0.0), Offset(-_size * 0.2, 0.0), _p);

    canvas.drawLine(Offset(_size * 0.2, _size * 0.2), Offset(_size, _size * 0.2), _p);
    canvas.drawLine(Offset(_size * 0.2, _size * 0.2), Offset(-_size * 0.2, 0.0), _p);

    canvas.drawLine(Offset(_size * 0.2, _size * 0.4), Offset(_size, _size * 0.4), _p);
    canvas.drawLine(Offset(_size * 0.2, _size * 0.4), Offset(-_size * 0.2, 0.0), _p);

    canvas.drawLine(Offset(_size * 0.2, _size * 0.6), Offset(_size, _size * 0.6), _p);
    canvas.drawLine(Offset(_size * 0.2, _size * 0.6), Offset(-_size * 0.2, 0.0), _p);

    canvas.drawRect(Rect.fromPoints(
      Offset(0.0, _size * 0.6),
      Offset(-_size * 0.8, -_size * 0.6),
    ), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.copper, state: FactoryMaterialState.plate): 6,
      FactoryRecipeMaterialType(FactoryMaterialType.iron, state: FactoryMaterialState.plate): 6,
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 20,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return ElectricBoard.custom(
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