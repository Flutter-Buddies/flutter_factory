part of factory_equipment;

class HydraulicPress extends FactoryEquipmentModel{
  HydraulicPress(Coordinates coordinates, Direction direction, {this.pressCapacity = 1, int tickDuration = 1}) : super(coordinates, direction, EquipmentType.hydraulic_press, tickDuration: tickDuration);

  final int pressCapacity;

  List<FactoryMaterialModel> _outputMaterial = <FactoryMaterialModel>[];

  @override
  HydraulicPress copyWith({Coordinates coordinates, Direction direction, int pressCapacity}) {
    return HydraulicPress(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      pressCapacity: pressCapacity ?? this.pressCapacity
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
    _outputMaterial = objects.getRange(0, min(pressCapacity, objects.length)).toList();
    objects.removeRange(0, min(pressCapacity, objects.length));
    _outputMaterial.forEach((FactoryMaterialModel m)=> m.changeState(FactoryMaterialState.plate));
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
    //    canvas.drawRect(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Paint()..color = Colors.grey.shade900);

    Path _machineLegs = Path();

    if(direction == Direction.east || direction == Direction.west){
      _machineLegs.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, size / 3.0)), bottomLeft: Radius.circular(size / 2.2 / 2), bottomRight: Radius.circular(size / 2.2 / 2)));
      _machineLegs.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(size / 2.2, -size / 2.2), Offset(-size / 2.2, -size / 3.0)), topLeft: Radius.circular(size / 2.2 / 2), topRight: Radius.circular(size / 2.2 / 2)));
    }else{
      _machineLegs.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(size / 3.0, -size / 2.2)), topRight: Radius.circular(size / 2.2 / 2), bottomRight: Radius.circular(size / 2.2 / 2)));
      _machineLegs.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(-size / 2.2, size / 2.2), Offset(-size / 3.0, -size / 2.2)), bottomLeft: Radius.circular(size / 2.2 / 2), topLeft: Radius.circular(size / 2.2 / 2)));
    }
//    _path.addRRect(RRect.fromRectAndCorners(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2))));
    canvas.drawPath(_machineLegs, Paint()..color = theme.machineAccentColor);


    double _change = Curves.easeInCubic.transform(_machineProgress) * 3;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)).deflate(_change), Radius.circular(size / 2.5 / 2)).deflate(_change), Paint()..color = theme.machineWarningColor);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.7, size / 2.7), Offset(-size / 2.7, -size / 2.7)).deflate(_change), Radius.circular(size / 2.7 / 2)).deflate(_change), Paint()..color = theme.machinePrimaryLightColor);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.0, size / 2.0), Offset(-size / 2.0, -size / 2.0)), Radius.circular(size / 2.5 / 2)), Paint()..color = Colors.white24);

    Path _machineTop = Path();
    if(direction == Direction.east || direction == Direction.west){
      _machineTop.addRect(Rect.fromPoints(Offset(size / 3.8, size / 2.2), Offset(size / 5.0, -size / 2.2)));
      _machineTop.addRect(Rect.fromPoints(Offset(-size / 3.8, size / 2.2), Offset(-size / 5.0, -size / 2.2)));
    }else{
      _machineTop.addRect(Rect.fromPoints(Offset(size / 2.2, size / 3.8), Offset(-size / 2.2, size / 5.0)));
      _machineTop.addRect(Rect.fromPoints(Offset(size / 2.2, -size / 3.8), Offset(-size / 2.2, -size / 5.0)));
    }
    canvas.drawPath(_machineTop, Paint()..color = theme.machineAccentLightColor);
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
    Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'press_capacity': pressCapacity
    });
    return _map;
  }
}