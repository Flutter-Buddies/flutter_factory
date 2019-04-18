import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Copper extends FactoryMaterial{
  Copper.fromOffset(Offset o) : super(o.dx, o.dy, FactoryMaterialType.copper);
}