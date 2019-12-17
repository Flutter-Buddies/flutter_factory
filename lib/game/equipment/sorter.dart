part of factory_equipment;

class Sorter extends FactoryEquipmentModel{
  Sorter(Coordinates coordinates, Direction equipmentDirection, this.directions) : super(coordinates, equipmentDirection, EquipmentType.sorter);

  final Map<FactoryRecipeMaterialType, Direction> directions;

  @override
  int get operatingCost => isActive ? directions.length * 5 : 0;

  @override
  List<FactoryMaterialModel> tick() {
    final List<FactoryMaterialModel> _fm = <FactoryMaterialModel>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterialModel fm){
      final FactoryRecipeMaterialType _frmt = directions.keys.firstWhere((FactoryRecipeMaterialType frmt) => frmt.materialType == fm.type && frmt.state == fm.state, orElse: () => null);
      fm.direction = directions.containsKey(_frmt) ? directions[_frmt] : direction;
      fm.moveMaterial(type);
    }).toList();

    return _fm;
  }

  bool _materialToDirection(FactoryMaterialModel fm, Direction direction){
    final FactoryRecipeMaterialType _frmt = directions.keys.firstWhere((FactoryRecipeMaterialType frmt) => frmt.materialType == fm.type && frmt.state == fm.state, orElse: () => null);
    if(_frmt == null){
      return false;
    }

    return fm.state == _frmt.state && directions[_frmt] == direction;
  }

  @override
  void drawTrack(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if(directions.containsValue(direction)){
      drawRoller(theme, direction, canvas, size, progress);
    }else{
      drawSplitter(theme, direction, canvas, size, progress);
    }

    directions.values.forEach((Direction d){
      if(d == direction){
        return;
      }else{
        drawSplitter(theme, d, canvas, size, progress);
      }
    });

    canvas.restore();
  }

  @override
  void paintInfo(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    super.paintInfo(theme, offset, canvas, size, progress);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(0.6);

    canvas.drawRect(Rect.fromPoints(
      Offset(-size * 0.8, 0.0),
      Offset(size * 0.8, size * 0.8),
    ), Paint()..color = Colors.black54);

    ParagraphBuilder _paragraphBuilder = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.start));
    _paragraphBuilder.pushStyle(TextStyle(color: Colors.white, fontSize: 6.0, fontWeight: FontWeight.w500));

    Direction.values.forEach((Direction d){
      _paragraphBuilder.addText('${directionToString(d)}\n');
    });

    Paragraph _paragraph = _paragraphBuilder.build();
    _paragraph.layout(ParagraphConstraints(width: size * 1.6));

    canvas.drawParagraph(_paragraph, Offset(-size * 0.8, size / 6));

    Direction.values.forEach((Direction d){
      List<FactoryRecipeMaterialType> _materials = directions.keys.where((FactoryRecipeMaterialType fmrt){
        return directions[fmrt] == d;
      }).toList();

      _materials.forEach((FactoryRecipeMaterialType fmt){
        canvas.save();
        canvas.translate(-size * 0.45 + (size * 0.5 * (_materials.indexOf(fmt) / _materials.length)), size * 0.24 * (d.index + 1));
        canvas.scale(0.5);

        FactoryMaterialModel.getFromType(fmt.materialType)..state = fmt.state..drawMaterial(Offset.zero, canvas, 0.0);

        canvas.restore();
      });
    });

    canvas.restore();
  }

  @override
  void drawEquipment(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)), Radius.circular(size / 2.2 / 2)), Paint()..color = theme.machineAccentColor);

    final Paint _gatesPaint = Paint();
    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.north || objects.indexWhere((FactoryMaterialModel fm) => _materialToDirection(fm, Direction.south)) != -1 || Direction.values[(direction.index - 2) % Direction.values.length] == Direction.north){
      _gatesPaint.color = theme.machineActiveColor;
    }else{
      _gatesPaint.color = theme.machineAccentLightColor;
    }

    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(-size * 0.02, -size / 2.2),
        Offset(size * 0.02, -size * 0.25),
      ),
      bottomLeft: Radius.circular(6.0),
      bottomRight: Radius.circular(6.0)
    ), _gatesPaint);

    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.south || objects.indexWhere((FactoryMaterialModel fm) => _materialToDirection(fm, Direction.north)) != -1 || Direction.values[(direction.index - 2) % Direction.values.length] == Direction.south){
      _gatesPaint.color = theme.machineActiveColor;
    }else{
      _gatesPaint.color = theme.machineAccentLightColor;
    }

    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(size * 0.02, size / 2.2),
        Offset(-size * 0.02, size * 0.25),
      ),
      topRight: Radius.circular(6.0),
      topLeft: Radius.circular(6.0)
    ), _gatesPaint);

    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.east || objects.indexWhere((FactoryMaterialModel fm) => _materialToDirection(fm, Direction.west)) != -1 || Direction.values[(direction.index - 2) % Direction.values.length] == Direction.east){
      _gatesPaint.color = theme.machineActiveColor;
    }else{
      _gatesPaint.color = theme.machineAccentLightColor;
    }

    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(-size / 2.2, -size * 0.02),
        Offset(-size * 0.25, size * 0.02),
      ),
      topRight: Radius.circular(6.0),
      bottomRight: Radius.circular(6.0),
    ), _gatesPaint);

    if(Direction.values[(direction.index - 2) % Direction.values.length] == Direction.west || objects.indexWhere((FactoryMaterialModel fm) => _materialToDirection(fm, Direction.east)) != -1 || Direction.values[(direction.index - 2) % Direction.values.length] == Direction.west){
      _gatesPaint.color = theme.machineActiveColor;
    }else{
      _gatesPaint.color = theme.machineAccentLightColor;
    }

    canvas.drawRRect(RRect.fromRectAndCorners(
      Rect.fromPoints(
        Offset(size / 2.2, size * 0.02),
        Offset(size * 0.25, -size * 0.02),
      ),
      topLeft: Radius.circular(6.0),
      bottomLeft: Radius.circular(6.0),
    ), _gatesPaint);

    canvas.restore();
  }

  @override
  void drawMaterial(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    objects.forEach((FactoryMaterialModel fm){
      double _moveX = 0.0;
      double _moveY = 0.0;

      final FactoryRecipeMaterialType _frmt = directions.keys.firstWhere((FactoryRecipeMaterialType frmt) => frmt.materialType == fm.type && frmt.state == fm.state, orElse: () => null);
      switch(directions.containsKey(_frmt) ? directions[_frmt] : direction){
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
  FactoryEquipmentModel copyWith({Coordinates coordinates, Direction direction, Map<FactoryRecipeMaterialType, Direction> directions}) {
    return Sorter(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      directions ?? <FactoryRecipeMaterialType, Direction>{}..addAll(this.directions)
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'sorter_directions': directions.keys.map((FactoryRecipeMaterialType type) => <String, int>{
        'material_type': type.materialType.index,
        'material_state': type.state.index,
        'direction': directions[type].index
      }).toList(),
    });

    print('Map: $_map');

    return _map;
  }
}