part of factory_equipment;

class Splitter extends FactoryEquipmentModel{
  Splitter(Coordinates coordinates, Direction equipmentDirection, this.directions) : super(coordinates, equipmentDirection, EquipmentType.splitter);

  final List<Direction> directions;

  int splitCounter = 0;

  @override
  List<FactoryMaterialModel> tick() {
    final List<FactoryMaterialModel> _fm = <FactoryMaterialModel>[]..addAll(objects);
    objects.clear();

    _fm.map((FactoryMaterialModel fm){
      fm.direction = directions[splitCounter % directions.length];
      fm.moveMaterial();
      splitCounter++;
    }).toList();

    return _fm;
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    directions.forEach((Direction d){
      if(d == Direction.values[(direction.index + 2) % Direction.values.length]){
        drawRoller(d, canvas, size, progress);
      }else{
        drawSplitter(d, canvas, size, progress);
      }
    });

    if(directions.contains(Direction.values[(direction.index + 2) % Direction.values.length])){
      canvas.save();
//      canvas.translate(0.0, -size / 4);
      drawRoller(Direction.values[(direction.index + 2) % Direction.values.length], canvas, size, progress);
      canvas.restore();
    }else{
      drawSplitter(Direction.values[(direction.index + 2) % Direction.values.length], canvas, size, progress, entry: true);
    }

    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress) {
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
  void paintInfo(Offset offset, Canvas canvas, double size, double progress) {
    super.paintInfo(offset, canvas, size, progress);

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
      directions ?? this.directions,
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