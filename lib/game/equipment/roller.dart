part of factory_equipment;

class Roller extends FactoryEquipmentModel{
  Roller(Coordinates coordinates, Direction direction, {int rollerTickDuration = 1}) : super(coordinates, direction, EquipmentType.roller, tickDuration: rollerTickDuration);

  @override
  List<FactoryMaterialModel> tick() {
    final List<FactoryMaterialModel> _fm = <FactoryMaterialModel>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterialModel fm){
      fm.direction = direction;
      fm.moveMaterial();
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    super.drawTrack(offset, canvas, size, progress);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if(direction == Direction.east || direction == Direction.west){
      canvas.drawRect(Rect.fromPoints(Offset(size / 3, size / 3), Offset(-size / 3, -size / 3)), Paint()..color = Colors.grey.shade800);
    }else{
      canvas.drawRect(Rect.fromPoints(Offset(size / 3, size / 3), Offset(-size / 3, -size / 3)), Paint()..color = Colors.grey.shade800);
    }

    void drawLines(Direction d, {bool entry = false}){
      switch(d){
        case Direction.west:
          for(int i = 0; i < 4; i++){
            double _xOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(_xOffset - size / 3 - size / 3 + size / 2, size / 3), Offset(_xOffset - size / 3 - size / 3 + size / 2, -size / 3), Paint()..color = Colors.white70);
          }
          break;
        case Direction.east:
          for(int i = 0; i < 4; i++){
            double _xOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(_xOffset - size / 3 - size / 3 + size / 2, size / 3), Offset(_xOffset - size / 3 - size / 3 + size / 2, -size / 3), Paint()..color = Colors.white70);
          }
          break;
        case Direction.south:
          for(int i = 0; i < 4; i++){
            double _yOffset = ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3 + size / 2), Offset(-size / 3, _yOffset - size / 3 - size / 3 + size / 2), Paint()..color = Colors.white70);
          }
          break;
        case Direction.north:
          for(int i = 0; i < 4; i++){
            double _yOffset = ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3 + size / 2), Offset(-size / 3, _yOffset - size / 3 - size / 3 + size / 2), Paint()..color = Colors.white70);
          }
          break;
      }
    }

    drawLines(direction);

    canvas.restore();
  }

  @override
  FactoryEquipmentModel copyWith({Coordinates coordinates, Direction direction, int tickDuration}) {
    return Roller(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      rollerTickDuration: tickDuration ?? this.tickDuration
    );
  }
}