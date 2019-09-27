part of factory_equipment;

class UndergroundPortal extends FactoryEquipmentModel{
  UndergroundPortal(Coordinates coordinates, Direction direction, {int portalTickDuration = 1, this.connectingPortal, this.isReceiver = false}) : super(coordinates, direction, EquipmentType.portal, tickDuration: portalTickDuration);

  Coordinates connectingPortal;

  bool isReceiver;
  int distance;

  final List<List<FactoryMaterialModel>> _backlog = <List<FactoryMaterialModel>>[];

  @override
  List<FactoryMaterialModel> tick() {
    final List<FactoryMaterialModel> _fm = <FactoryMaterialModel>[]..addAll(objects);
    objects.clear();

    if(connectingPortal != null){
      distance ??= (coordinates.x - connectingPortal.x).abs() + (coordinates.y - connectingPortal.y).abs();
    }

    if(isReceiver){
      _backlog.add(_fm);

      if(_backlog.length > (distance ?? 0)){
        List<FactoryMaterialModel> _list = <FactoryMaterialModel>[]..addAll(_backlog.first);
        _backlog.removeAt(0);

        _list.forEach((FactoryMaterialModel fmm){
          fmm.direction = direction;
          fmm.moveMaterial();
        });
        return _list;
      }

      return <FactoryMaterialModel>[];
    }

    if(connectingPortal != null){
      _fm.map((FactoryMaterialModel fm){
        fm.direction = direction;
        fm.x = connectingPortal.x.toDouble();
        fm.y = connectingPortal.y.toDouble();
      }).toList();
    }else{
      _fm.clear();
    }

    return _fm;
  }

  @override
  void drawTrack(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    if(isReceiver){
      super.drawTrack(theme, offset, canvas, size, progress);
    }

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
  void drawMaterial(GameTheme theme, Offset offset, Canvas canvas, double size, double progress){
    double _moveX = 0.0;
    double _moveY = 0.0;

    if(_backlog.isEmpty || _backlog.first.isEmpty || _backlog.length < distance){
      return;
    }

    switch(direction){
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

    _backlog.first.forEach((FactoryMaterialModel fm) => fm.drawMaterial(offset + Offset(_moveX + fm.offsetX, _moveY + fm.offsetY), canvas, progress));
  }

  @override
  void drawEquipment(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)),
      Radius.circular(size / 2.2 / 2)
    ), Paint()..color = theme.machinePrimaryColor);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.8, size / 2.8), Offset(-size / 2.8, -size / 2.8)),
        Radius.circular(size / 2.8 / 2)
      ), Paint()..color = connectingPortal != null ? isReceiver ? theme.machineActiveColor : theme.machineWarningColor : theme.machineInActiveColor);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 4.0, size / 4.0), Offset(-size / 4.0, -size / 4.0)),
        Radius.circular(size / 4.0 / 2)
      ), Paint()..color = theme.machineAccentDarkColor);

    canvas.restore();
  }

  @override
  FactoryEquipmentModel copyWith({Coordinates coordinates, bool isReceiver, Direction direction, int tickDuration, UndergroundPortal connectingPortal}) {
    return UndergroundPortal(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      portalTickDuration: tickDuration ?? this.tickDuration,
      isReceiver: isReceiver ?? this.isReceiver,
    );
  }

  @override
  Map<String, dynamic> toMap(){
    final Map<String, dynamic> _myMap = super.toMap();

    if(connectingPortal != null){
      _myMap.addAll(<String, dynamic>{
        'connecting_portal': connectingPortal.toMap()
      });
    }

    _myMap.addAll(<String, dynamic>{
      'receiver': isReceiver
    });

    return _myMap;
  }
}