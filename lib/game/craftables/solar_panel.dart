part of factory_material;

class SolarPanel extends FactoryMaterialModel{
  SolarPanel.fromOffset(Offset o) : super(o.dx, o.dy, 900.0, FactoryMaterialType.solarPanel, state: FactoryMaterialState.crafted);

  SolarPanel.custom({double x, double y, double value, double size = 8.0, FactoryMaterialState state = FactoryMaterialState.crafted, double rotation, double offsetX, double offsetY}) :
      super.custom(x: x, y: y, value: value, type: FactoryMaterialType.solarPanel, size: size, state: state, rotation: rotation, offsetX: offsetX, offsetY: offsetY);

  @override
  void drawMaterial(Offset offset, Canvas canvas, double progress, {double opacity = 1.0}){
    final Paint _p = Paint();
    final double _size = size * 0.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final Path _frame = Path();

    _frame.addRRect(RRect.fromRectAndRadius(Rect.fromPoints(
      Offset(_size * 0.8, _size * 0.8),
      Offset(-_size * 0.8, -_size * 0.8),
    ), Radius.circular(_size * 0.05)));

    canvas.drawPath(_frame, _p..color = Colors.blue.shade600.withOpacity(opacity));

    _p.color = Colors.black.withOpacity(opacity);
    _p.strokeWidth = 0.6;
    _p.style = PaintingStyle.stroke;
    canvas.drawPath(_frame, _p);

    _p.strokeWidth = 0.1;

    for(int i = 1; i < 4; i++){
      canvas.drawLine(
        Offset(_size * 0.8 - (_size * 1.2 * (i / 3)), _size * 0.8),
        Offset(_size * 0.8 - (_size * 1.2 * (i / 3)), -_size * 0.8),
        _p
      );
    }

    canvas.drawLine(
      Offset(
        _size * 0.8,
        0.0
      ),
      Offset(
        -_size * 0.8,
        0.0
      ), _p);

    canvas.restore();
  }

  @override
  Map<FactoryRecipeMaterialType, int> getRecipe() {
    return <FactoryRecipeMaterialType, int>{
      FactoryRecipeMaterialType(FactoryMaterialType.computerChip): 1,
      FactoryRecipeMaterialType(FactoryMaterialType.gold): 2,
      FactoryRecipeMaterialType(FactoryMaterialType.diamond): 1,
    };
  }

  @override
  FactoryMaterialModel copyWith({double x, double y, double size, double value, FactoryMaterialType type}) {
    return SolarPanel.custom(
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