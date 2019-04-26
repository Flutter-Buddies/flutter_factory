import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Seller extends FactoryEquipment{
  Seller(Coordinates coordinates, Direction direction) : super(coordinates, direction, EquipmentType.seller);

  final List<double> _tickSellings = <double>[];
  double soldValue = 0;
  double soldAverage = 0;

  @override
  FactoryEquipment copyWith({Coordinates coordinates, Direction direction}) {
    return Seller(
      coordinates ?? this.coordinates,
      direction ?? this.direction
    );
  }

  @override
  List<FactoryMaterial> tick() {
    soldValue = 0;

    objects.forEach((FactoryMaterial fm){
      soldValue += fm.value;
    });

    _tickSellings.add(soldValue);

    if(_tickSellings.length > 100){
      _tickSellings.removeAt(0);
    }

    soldAverage = _tickSellings.fold(0.0, (double count, double value) => count += value) / _tickSellings.length;

    objects.clear();

    return <FactoryMaterial>[];
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress){
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)), Radius.circular(size / 2.2 / 2)), Paint()..color = Colors.green.shade800);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Radius.circular(size / 2.5 / 2)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.8, size / 2.8), Offset(-size / 2.8, -size / 2.8)), Radius.circular(size / 2.8 / 2)), Paint()..color = Colors.green);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 3.0, size / 3.0), Offset(-size / 3.0, -size / 3.0)), Radius.circular(size / 3.0 / 2)), Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress) {
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress) {
  }
}