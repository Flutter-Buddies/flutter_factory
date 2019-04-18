import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_material.dart';

class Gold extends FactoryMaterial{
  Gold.fromOffset(Offset o) : super(o.dx, o.dy, FactoryMaterialType.gold);
}