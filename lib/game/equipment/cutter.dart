part of factory_equipment;

class Cutter extends FactoryEquipmentModel{
  Cutter(Coordinates coordinates, Direction direction, {this.cutCapacity = 1, int tickDuration = 1}) : super(coordinates, direction, EquipmentType.cutter, tickDuration: tickDuration);

  final int cutCapacity;

  List<FactoryMaterialModel> _outputMaterial = <FactoryMaterialModel>[];

  @override
  Cutter copyWith({Coordinates coordinates, Direction direction, int cutCapacity}) {
    return Cutter(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      cutCapacity: cutCapacity ?? this.cutCapacity
    );
  }

  @override
  List<FactoryMaterialModel> tick() {
    if(tickDuration > 1 && counter % tickDuration != 1 && _outputMaterial.isEmpty){
      return <FactoryMaterialModel>[];
    }

    if(tickDuration == 1){
      final List<FactoryMaterialModel> _fm = <FactoryMaterialModel>[]..addAll(_outputMaterial);
      _outputMaterial.clear();
      _processMaterial();

      _fm.map((FactoryMaterialModel fm){
        fm.direction = direction;
        fm.moveMaterial(type);
      }).toList();

      return _fm;
    }

    if(_outputMaterial.isEmpty){
      _processMaterial();
      return <FactoryMaterialModel>[];
    }

    final List<FactoryMaterialModel> _material = <FactoryMaterialModel>[]..addAll(_outputMaterial);
    _outputMaterial.clear();

    _material.map((FactoryMaterialModel fm){
      fm.direction = direction;
      fm.moveMaterial(type);
    }).toList();

    return _material;
  }

  void _processMaterial(){
    _outputMaterial = objects.getRange(0, min(cutCapacity, objects.length)).toList();
    objects.removeRange(0, min(cutCapacity, objects.length));
    _outputMaterial.forEach((FactoryMaterialModel m)=> m.changeState(FactoryMaterialState.gear));
  }

  @override
  void drawEquipment(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    double _myProgress = ((counter % tickDuration) / tickDuration) + (progress / tickDuration);
    double _machineProgress = (counter % tickDuration) >= (tickDuration / 2) ? _myProgress : (1 - _myProgress);

    if(tickDuration == 1){
      _machineProgress = (_myProgress > 0.5) ? ((_myProgress * 2) - 1) : (1 - (_myProgress * 2));
    }

    if(objects.isEmpty && _outputMaterial.isEmpty){
      _machineProgress = 0.0;
    }

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4)), Radius.circular(size / 2.4 / 2)), Paint()..color = theme.machinePrimaryLightColor);

    final double _change = Curves.easeInOut.transform(_machineProgress);

    if(direction == Direction.south || direction == Direction.north){
      canvas.drawLine(Offset(size / 2.4, size / 2.4), Offset(size / 2.4, -size / 2.4), Paint()..color = theme.machinePrimaryDarkColor..strokeWidth = 1.6);
      canvas.drawLine(Offset(-size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4), Paint()..color = theme.machinePrimaryDarkColor..strokeWidth = 1.6);

      canvas.drawLine(Offset(-size / 2.4, (size / 1.2) * _change - (size / 2.4)), Offset(size / 2.4, (size / 1.2) * _change - (size / 2.4)), Paint()..color = theme.machineInActiveColor..strokeWidth = 0.8);
    }else{
      canvas.drawLine(Offset(size / 2.4, -size / 2.4), Offset(-size / 2.4, -size / 2.4), Paint()..color = theme.machinePrimaryDarkColor..strokeWidth = 1.6);
      canvas.drawLine(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, size / 2.4), Paint()..color = theme.machinePrimaryDarkColor..strokeWidth = 1.6);

      canvas.drawLine(Offset((size / 1.2) * _change - (size / 2.4), -size / 2.4), Offset((size / 1.2) * _change - (size / 2.4), size / 2.4), Paint()..color = theme.machineInActiveColor..strokeWidth = 0.8);
    }

    canvas.restore();
  }

  @override
  void drawTrack(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    drawRoller(theme, direction, canvas, size, progress);
    canvas.restore();
  }

  @override
  void drawMaterial(GameTheme theme, Offset offset, Canvas canvas, double size, double progress){
    double _moveX = 0.0;
    double _moveY = 0.0;

    if(_outputMaterial.isEmpty){
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

    _outputMaterial.forEach((FactoryMaterialModel fm) => fm.drawMaterial(offset + Offset(_moveX + fm.offsetX, _moveY + fm.offsetY), canvas, progress));
  }


  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'cut_capacity': cutCapacity
    });
    return _map;
  }
}