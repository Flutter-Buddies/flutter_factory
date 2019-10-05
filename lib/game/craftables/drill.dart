part of factory_material;

class Drill extends FactoryMaterialModel{
  Drill.fromOffset(Offset o) : super(o.dx, o.dy, 1500.0, FactoryMaterialType.drill, state: FactoryMaterialState.crafted);

  Drill.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.drill, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    Paint _p = Paint();

    double _size = size * 0.4;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRect(Rect.fromPoints(Offset(-_size * 0.8, -_size * 0.8), Offset(_size * 0.6, -_size * 0.2)));
    _frame.addRect(Rect.fromPoints(Offset(-_size * 0.8, -_size * 0.2), Offset(-_size * 0.4, _size * 0.6)));

    final Path _details = Path();
    _details.addArc(Rect.fromPoints(Offset(_size * 0.5, -_size * 0.8), Offset(_size * 0.8, -_size * 0.2)), -pi / 2, pi);


    canvas.drawPath(_frame, _p..color = Colors.yellow.withOpacity(opacity));
    canvas.drawPath(_details, _p..color = Colors.grey.withOpacity(opacity));
    canvas.drawLine(Offset(_size * 0.8, -_size * 0.5), Offset(_size, -_size * 0.5), Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 0.2);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.diamond): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.copper, state: FactoryMaterialState.gear): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.engine): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Drill.custom(
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