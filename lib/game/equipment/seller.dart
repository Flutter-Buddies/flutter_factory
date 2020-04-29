part of factory_equipment;

class Seller extends FactoryEquipmentModel {
  Seller(Coordinates coordinates, Direction direction, {bool isMutable = true})
      : super(coordinates, direction, EquipmentType.seller, isMutable: isMutable);

  final List<double> _tickSellings = <double>[];
  final List<List<FactoryRecipeMaterialType>> soldItems = <List<FactoryRecipeMaterialType>>[];
  double soldValue = 0;
  double soldAverage = 0;

  bool _startSelling = false;

  @override
  int get operatingCost => 0;

  @override
  FactoryEquipmentModel copyWith({Coordinates coordinates, Direction direction}) {
    return Seller(coordinates ?? this.coordinates, direction ?? this.direction);
  }

  @override
  List<FactoryMaterialModel> tick() {
    soldValue = 0;

    if (objects.isNotEmpty) {
      _startSelling = true;
    }

    void _getMaterialValue(FactoryMaterialModel fm) {
      soldValue += fm.value;
    }

    objects.forEach(_getMaterialValue);

    if (soldItems.length > 90) {
      soldItems.removeRange(0, 30);
    }

    if (_startSelling) {
      soldItems.add(objects
          .map<FactoryRecipeMaterialType>(
              (FactoryMaterialModel fmt) => FactoryRecipeMaterialType(fmt.type, state: fmt.state))
          .toList());
    }
    _tickSellings.add(soldValue);

    if (_tickSellings.length > 100) {
      _tickSellings.removeAt(0);
    }

    soldAverage = _tickSellings.fold(0.0, (double count, double value) => count += value) / _tickSellings.length;

    objects.clear();

    return <FactoryMaterialModel>[];
  }

  @override
  void drawEquipment(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)),
            Radius.circular(size / 2.2 / 2)),
        Paint()..color = theme.machineActiveColor);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)),
            Radius.circular(size / 2.5 / 2)),
        Paint()..color = theme.machineAccentColor);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.8, size / 2.8), Offset(-size / 2.8, -size / 2.8)),
            Radius.circular(size / 2.8 / 2)),
        Paint()..color = theme.machineActiveColor);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 3.0, size / 3.0), Offset(-size / 3.0, -size / 3.0)),
            Radius.circular(size / 3.0 / 2)),
        Paint()..color = theme.machineAccentLightColor);
    canvas.restore();
  }

  @override
  void drawTrack(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {}

  @override
  void drawMaterial(GameTheme theme, Offset offset, Canvas canvas, double size, double progress) {}
}
