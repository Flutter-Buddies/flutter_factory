part of factory_equipment;

class WireBender extends FactoryEquipmentModel{
  WireBender(Coordinates coordinates, Direction direction, {this.wireCapacity = 1, int tickDuration = 1}) : super(coordinates, direction, EquipmentType.wire_bender, tickDuration: tickDuration);

  final int wireCapacity;

  List<FactoryMaterialModel> _outputMaterial = <FactoryMaterialModel>[];

  @override
  WireBender copyWith({Coordinates coordinates, Direction direction, int wireCapacity}) {
    return WireBender(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      wireCapacity: wireCapacity ?? this.wireCapacity
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
    _outputMaterial = objects.getRange(0, min(wireCapacity, objects.length)).toList();
    objects.removeRange(0, min(wireCapacity, objects.length));
    _outputMaterial.forEach((FactoryMaterialModel m)=> m.changeState(FactoryMaterialState.spring));
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

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4)), Radius.circular(size / 2.4 / 2)), Paint()..color = theme.machineAccentColor);

    final double _change = Curves.elasticInOut.transform(_machineProgress) * 6.28;
    final double _size = size / 4.2;
    final Paint _linesPaint = Paint();

    _linesPaint.strokeWidth = 0.6;
    _linesPaint.strokeJoin = StrokeJoin.round;
    _linesPaint.color = theme.machinePrimaryDarkColor;
    canvas.drawLine(Offset(0.0, 0.0), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);
    _linesPaint.color = theme.machinePrimaryLightColor.withOpacity(0.4);
    canvas.drawLine(Offset(-size / 4, size / 4), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);
    canvas.drawLine(Offset(size / 4, size / 4), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);
    canvas.drawLine(Offset(size / 4, -size / 4), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);
    canvas.drawLine(Offset(-size / 4, -size / 4), Offset(cos(_change) * _size, sin(_change) * _size), _linesPaint);

//    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)).deflate(_change), Radius.circular(size / 2.5 / 2)).deflate(_change), Paint()..color = Colors.yellow);
//    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.7, size / 2.7), Offset(-size / 2.7, -size / 2.7)).deflate(_change), Radius.circular(size / 2.7 / 2)).deflate(_change), Paint()..color = Colors.grey.shade700);

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
      'wire_capacity': wireCapacity
    });
    return _map;
  }
}