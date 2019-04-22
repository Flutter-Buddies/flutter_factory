import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Aluminium extends FactoryMaterial{
  Aluminium.fromOffset(Offset o) : super(o.dx, o.dy, FactoryMaterialType.aluminium);
}