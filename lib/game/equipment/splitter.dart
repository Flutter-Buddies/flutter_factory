part of factory_equipment;

class Splitter extends FactoryEquipmentModel{
  Splitter(Coordinates coordinates, Direction equipmentDirection, this.directions) : _direction = equipmentDirection, super(coordinates, equipmentDirection, EquipmentType.splitter);

  final List<Direction> directions;

  Direction _direction;

  @override
  int get operatingCost => isActive ? directions.length * 5 : 0;

  @override
  set direction(Direction d){
    _direction ??= d;

    final int _difference = d.index - _direction.index;
    _direction = d;

    final List<Direction> _dir = <Direction>[]..addAll(directions);

    directions.clear();
    directions.addAll(_dir.map((Direction d) => Direction.values[(d.index + _difference) % Direction.values.length]));
  }

  @override
  Direction get direction => _direction;

  int splitCounter = 0;

  @override
  List<FactoryMaterialModel> tick() {
    final List<FactoryMaterialModel> _fm = <FactoryMaterialModel>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterialModel fm){
      fm.direction = directions[splitCounter % directions.length];
      fm.moveMaterial(type);
      splitCounter++;
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final List<Direction> _myDir = inputDirections.keys.toList();
    final List<Direction> _candidates = <Direction>[]..addAll(directions);

    if(_myDir.isEmpty){
      final Direction _defaultDirection = Direction.values[(_direction.index + 2) % Direction.values.length];

      if(directions.contains(_defaultDirection)){
        drawRoller(theme, _defaultDirection, canvas, size, progress);
      }else{
        drawSplitter(theme, _defaultDirection, canvas, size, progress, entry: true);
      }

      _candidates.remove(_defaultDirection);
    }else{
      _myDir.forEach((Direction d){
        if(directions.contains(d)){
          drawRoller(theme, d, canvas, size, progress);
        }else{
          drawSplitter(theme, d, canvas, size, progress, entry: true);
        }
      });
    }

    _candidates.forEach((Direction d){
      drawSplitter(theme, d, canvas, size, progress);
    });


    canvas.restore();
  }

  @override
  void drawMaterial(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    objects.forEach((FactoryMaterialModel fm){
      double _moveX = 0.0;
      double _moveY = 0.0;

      switch(directions[(objects.indexOf(fm) + splitCounter) % directions.length]){
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
    super.paintInfo(theme, offset, canvas, size, progress);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(0.6);

    canvas.drawRect(Rect.fromPoints(
      Offset(-size * 0.8, 0.0),
      Offset(size * 0.8, size * 0.8),
    ), Paint()..color = Colors.black54);

    ParagraphBuilder _paragraphBuilder = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center));
    _paragraphBuilder.pushStyle(TextStyle(color: Colors.white, fontSize: 6.0, fontWeight: FontWeight.w500));

    Direction.values.forEach((Direction d){
      _paragraphBuilder.addText('${directionToString(d)} x ${directions.where((Direction dd) => dd == d).length ?? 0}${d.index == 1 ? '\n' : '  '}');
    });

    Paragraph _paragraph = _paragraphBuilder.build();
    _paragraph.layout(ParagraphConstraints(width: size * 2));

    canvas.drawParagraph(_paragraph, Offset(-size, size / 6));


    canvas.restore();
  }

  @override
  FactoryEquipmentModel copyWith({Coordinates coordinates, Direction direction, List<Direction> directions}) {
    return Splitter(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      directions ?? <Direction>[]..addAll(this.directions),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'splitter_directions': directions.map((Direction d) => d.index).toList()
    });
    return _map;
  }
}