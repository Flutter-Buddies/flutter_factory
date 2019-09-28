part of factory_equipment;

class Melter extends FactoryEquipmentModel{
  Melter(Coordinates coordinates, Direction direction, {this.meltCapacity = 1, int tickDuration = 1}) : super(coordinates, direction, EquipmentType.melter, tickDuration: tickDuration);

  final int meltCapacity;

  List<FactoryMaterialModel> _outputMaterial = <FactoryMaterialModel>[];

  @override
  Melter copyWith({Coordinates coordinates, Direction direction, int meltCapacity}) {
    return Melter(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      meltCapacity: meltCapacity ?? this.meltCapacity
    );
  }

  @override
  List<FactoryMaterialModel> tick() {
    if(tickDuration > 1 && counter % tickDuration != 1 && _outputMaterial.isEmpty){
      print('Not ticking!');
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
    _outputMaterial = objects.getRange(0, min(meltCapacity, objects.length)).toList();
    objects.removeRange(0, min(meltCapacity, objects.length));
    _outputMaterial.forEach((FactoryMaterialModel m)=> m.changeState(FactoryMaterialState.fluid));
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

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4)), Radius.circular(size / 2.4 / 2)), Paint()..color = theme.machineAccentLightColor);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.6, size / 2.6), Offset(-size / 2.6, -size / 2.6)), Radius.circular(size / 2.6 / 2)), Paint()..color = Color.lerp(theme.machineAccentLightColor, theme.melterActiveColor, _machineProgress));

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
      'melt_capacity': meltCapacity
    });
    return _map;
  }
}