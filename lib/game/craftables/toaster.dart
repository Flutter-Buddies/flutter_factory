part of factory_material;

class Toaster extends FactoryMaterialModel{
  Toaster.fromOffset(Offset o) : super(o.dx, o.dy, 900.0, FactoryMaterialType.toaster, state: FactoryMaterialState.crafted);

  Toaster.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.raw, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.toaster, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    final Paint _p = Paint();
    final double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(
      Offset(_size * 0.6, _size * 0.7),
      Offset(-_size * 0.6, 0.0),
    ), topLeft: Radius.circular(_size * 0.2), topRight: Radius.circular(_size * 0.2)));

    canvas.drawPath(_frame, _p..color = Colors.grey.withOpacity(opacity));

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.2;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);

    _p.style = PaintingStyle.fill;
    _p.color = Colors.black;
    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(-_size * 0.75, _size * 0.7),
        Offset(-_size * 0.6, _size * 0.6),
      )
    ), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.heaterPlate): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.aluminium): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.copper): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return Toaster.custom(
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