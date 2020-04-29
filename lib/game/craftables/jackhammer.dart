part of factory_material;

class JackHammer extends FactoryMaterialModel{
  JackHammer.fromOffset(Offset o) : super(o.dx, o.dy, 6920.0, FactoryMaterialType.jackHammer, state: FactoryMaterialState.crafted);

  JackHammer.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.jackHammer, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    final Paint _p = Paint();
    final double _size = size * 0.5;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.moveTo(-_size * 0.4, -_size * 0.7);

    _frame.lineTo(-_size * 0.2, _size * 0.6);
    _frame.lineTo(_size * 0.2, _size * 0.6);
    _frame.lineTo(_size * 0.4, -_size * 0.7);

    _frame.close();

    canvas.drawPath(_frame, _p..color = Colors.grey.withOpacity(opacity));

    canvas.drawRect(Rect.fromPoints(Offset(-_size * 0.1, -_size * 0.7), Offset(_size * 0.1, -_size * 0.9)), _p);
    canvas.drawRect(Rect.fromPoints(Offset(-_size * 0.5, -_size * 0.9), Offset(_size * 0.5, -_size)), _p);

    canvas.drawRect(Rect.fromPoints(Offset(-_size * 0.5, -_size * 0.9), Offset(-_size * 0.1, -_size)), _p..color = Colors.grey.shade800.withOpacity(opacity));
    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.5, -_size * 0.9), Offset(_size * 0.1, -_size)), _p);

    _p.color = Colors.grey.shade300.withOpacity(opacity);
    canvas.drawRect(Rect.fromPoints(Offset(-_size * 0.02, _size * 0.6), Offset(_size * 0.02, _size)), _p);

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.2;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.iron, state: FactoryMaterialState.plate): 4,
      FactoryRecipeMaterialType(FactoryMaterialType.diamond): 4,
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 4,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return JackHammer.custom(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      value: value ?? this.value,
      state: state,
      rotation: rotation,
      offsetX: offsetX,
      offsetY: offsetY,
    );
  }
}