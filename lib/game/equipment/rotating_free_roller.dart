part of factory_equipment;

class RotatingFreeRoller extends FactoryEquipmentModel{
  RotatingFreeRoller(Coordinates coordinates, Direction equipmentDirection, {int tickDuration, this.rotation = 1}) : super(coordinates, equipmentDirection, EquipmentType.rotatingFreeRoller, tickDuration: tickDuration);

  int rotation;

  @override
  List<FactoryMaterialModel> tick() {
    final List<FactoryMaterialModel> _fm = <FactoryMaterialModel>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterialModel fm){
      fm.direction = Direction.values[(fm.direction.index + rotation) % Direction.values.length];
      fm.moveMaterial();
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(GameTheme theme, Offset offset, Canvas canvas, double size, double progress){
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    double _size = size * 0.8;

    drawRoller(theme, Direction.north, canvas, size, progress);
    drawRoller(theme, Direction.west, canvas, size, progress);
    drawRoller(theme, Direction.east, canvas, size, progress);
    drawRoller(theme, Direction.south, canvas, size, progress);

    canvas.drawRect(Rect.fromPoints(Offset(_size * 0.4, _size * 0.4), Offset(-_size * 0.4, -_size * 0.4)), Paint()..color = theme.floorColor);

//    for(int i = 0; i < 8; i++){
//      for(int j = 0; j < 8; j++){
//        canvas.drawCircle(Offset(_size * 0.35 + (i * (-_size * 0.1)), _size * 0.35 + (j * (-_size * 0.1))), _size * 0.045, Paint()..color = Colors.black54);
//      }
//    }
    canvas.drawCircle(Offset(0.0, 0.0), _size * 0.4, Paint()..color = theme.rollersColor);

    canvas.drawLine(
      Offset(cos((rotation == 1 ? progress : -progress) * pi * 2) * _size * 0.1, sin((rotation == 1 ? progress : -progress) * pi * 2) * _size * 0.1),
      Offset(cos((rotation == 1 ? progress : -progress) * pi * 2) * _size * 0.4, sin((rotation == 1 ? progress : -progress) * pi * 2) * _size * 0.4),
      Paint()..color = theme.machinePrimaryLightColor..strokeWidth = 1.0
    );

    canvas.restore();
  }

  @override
  void drawMaterial(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    objects.forEach((FactoryMaterialModel fm){
      double _moveX = 0.0;
      double _moveY = 0.0;

      switch(Direction.values[(fm.direction.index + rotation) % Direction.values.length]){
        case Direction.east:
          _moveX = progress * size;
          break;
        case Direction.west:
          _moveX = -progress * size;
          break;
        case Direction.north:
          _moveY = progress * size;
          break;
        case Direction.south:
          _moveY = -progress * size;
          break;
      }

      fm.drawMaterial(offset + Offset(fm.offsetX + _moveX, fm.offsetY + _moveY), canvas, progress);
    });
  }

  @override
  void paintInfo(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(0.6);

    Paint _p = Paint()..color = Colors.red..style = PaintingStyle.stroke..strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, size * 0.6, _p);

    canvas.restore();
  }

  @override
  FactoryEquipmentModel copyWith({Coordinates coordinates, Direction direction, List<Direction> directions}) {
    return RotatingFreeRoller(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
    );
  }
}