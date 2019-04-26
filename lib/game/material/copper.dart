import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Copper extends FactoryMaterial{
  Copper.fromOffset(Offset o) : super(o.dx, o.dy, 50.0, FactoryMaterialType.copper);
}