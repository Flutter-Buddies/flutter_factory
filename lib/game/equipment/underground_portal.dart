part of factory_equipment;

class UndergroundPortal extends FactoryEquipmentModel {
  UndergroundPortal(Coordinates coordinates, Direction direction, {int portalTickDuration = 1, this.connectingPortal})
      : super(coordinates, direction, EquipmentType.portal, tickDuration: portalTickDuration);

  Coordinates connectingPortal;
  int distance;

  @override
  int get operatingCost => _backlog.isNotEmpty ? distance * 5 : 0;

  Color lineColor;

  final List<List<FactoryMaterialModel>> _backlog = <List<FactoryMaterialModel>>[];

  @override
  List<FactoryMaterialModel> tick() {
    final List<FactoryMaterialModel> _inputMaterial =
        objects.where((FactoryMaterialModel fmm) => fmm.lastEquipment != EquipmentType.portal).toList();
    final List<FactoryMaterialModel> _outputMaterial = <FactoryMaterialModel>[];

    if (connectingPortal != null) {
      _outputMaterial.addAll(objects.where((FactoryMaterialModel fmm) => fmm.lastEquipment == EquipmentType.portal));
      distance = (coordinates.x - connectingPortal.x).abs() + (coordinates.y - connectingPortal.y).abs();
    }

    final List<FactoryMaterialModel> _returnList = <FactoryMaterialModel>[];

    if (_inputMaterial.isNotEmpty && connectingPortal != null) {
      _returnList.addAll(_inputMaterial.map((FactoryMaterialModel fm) {
        fm.direction = direction;
        fm.x = connectingPortal.x.toDouble();
        fm.y = connectingPortal.y.toDouble();
        fm.lastEquipment = type;

        return fm;
      }));
    }

    if (_outputMaterial.isNotEmpty) {
      _backlog.add(_outputMaterial);

      if (_backlog.length >= (distance ?? 0)) {
        final List<FactoryMaterialModel> _list = <FactoryMaterialModel>[]..addAll(_backlog.first);
        _backlog.remove(_backlog.first);

        void _moveMaterial(FactoryMaterialModel fmm) {
          fmm.direction = direction;
          fmm.moveMaterial(null);
        }

        _list.forEach(_moveMaterial);

        _returnList.addAll(_list);
      }
    }

    objects.clear();

    return _returnList;
  }

  @override
  void drawTrack(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    super.drawTrack(theme, offset, canvas, size, progress);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if (direction == Direction.east || direction == Direction.west) {
      canvas.drawRect(Rect.fromPoints(Offset(size / 3, size / 3), Offset(-size / 3, -size / 3)),
          Paint()..color = Colors.grey.shade800);
    } else {
      canvas.drawRect(Rect.fromPoints(Offset(size / 3, size / 3), Offset(-size / 3, -size / 3)),
          Paint()..color = Colors.grey.shade800);
    }

    void drawLines(Direction d, {bool entry = false}) {
      switch (d) {
        case Direction.west:
          for (int i = 0; i < 4; i++) {
            final double _xOffset =
                ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(_xOffset - size / 3 - size / 3 + size / 2, size / 3),
                Offset(_xOffset - size / 3 - size / 3 + size / 2, -size / 3), Paint()..color = Colors.white70);
          }
          break;
        case Direction.east:
          for (int i = 0; i < 4; i++) {
            final double _xOffset =
                ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(_xOffset - size / 3 - size / 3 + size / 2, size / 3),
                Offset(_xOffset - size / 3 - size / 3 + size / 2, -size / 3), Paint()..color = Colors.white70);
          }
          break;
        case Direction.south:
          for (int i = 0; i < 4; i++) {
            final double _yOffset =
                ((size / 6) * i + (entry ? progress : -progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3 + size / 2),
                Offset(-size / 3, _yOffset - size / 3 - size / 3 + size / 2), Paint()..color = Colors.white70);
          }
          break;
        case Direction.north:
          for (int i = 0; i < 4; i++) {
            final double _yOffset =
                ((size / 6) * i + (entry ? -progress : progress) * size) % (size / 1.5) - size / 3 / 2;
            canvas.drawLine(Offset(size / 3, _yOffset - size / 3 - size / 3 + size / 2),
                Offset(-size / 3, _yOffset - size / 3 - size / 3 + size / 2), Paint()..color = Colors.white70);
          }
          break;
      }
    }

    drawLines(direction);

    canvas.restore();
  }

  @override
  void drawMaterial(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    double _moveX = 0.0;
    double _moveY = 0.0;

    if (_backlog.isEmpty || _backlog.first.isEmpty || _backlog.length < (distance - 1)) {
      return;
    }

    switch (direction) {
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

    void _drawMaterial(FactoryMaterialModel fm) =>
        fm.drawMaterial(offset + Offset(_moveX + fm.offsetX, _moveY + fm.offsetY), canvas, progress);

    _backlog.first.forEach(_drawMaterial);
  }

  @override
  void drawEquipment(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)),
            Radius.circular(size / 2.2 / 2)),
        Paint()..color = theme.machinePrimaryColor);

    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.8, size / 2.8), Offset(-size / 2.8, -size / 2.8)),
            Radius.circular(size / 2.8 / 2)),
        Paint()
          ..color = connectingPortal != null
              ? lineColor != null ? lineColor : theme.machineActiveColor
              : theme.machineInActiveColor);

    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 3.4, size / 3.4), Offset(-size / 3.4, -size / 3.4)),
            Radius.circular(size / 3.4 / 2)),
        Paint()..color = theme.machineAccentDarkColor);

    canvas.restore();
  }

  @override
  FactoryEquipmentModel copyWith(
      {Coordinates coordinates,
      bool isReceiver,
      Direction direction,
      int tickDuration,
      UndergroundPortal connectingPortal}) {
    return UndergroundPortal(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      portalTickDuration: tickDuration ?? this.tickDuration,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _myMap = super.toMap();

    if (connectingPortal != null) {
      _myMap.addAll(<String, dynamic>{'connecting_portal': connectingPortal.toMap()});
    }

    _myMap.remove('material');
    _myMap.addAll(<String, dynamic>{'material': <Map<String, dynamic>>[]});

    return _myMap;
  }
}
