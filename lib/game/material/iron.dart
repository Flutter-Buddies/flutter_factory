import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Iron extends FactoryMaterial{
  Iron.fromOffset(Offset o) : super(o.dx, o.dy, FactoryMaterialType.iron);
}