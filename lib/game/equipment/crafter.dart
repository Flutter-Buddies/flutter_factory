part of factory_equipment;

class Crafter extends FactoryEquipmentModel{
  Crafter(Coordinates coordinates, Direction direction, this.craftMaterial, {int craftingTickDuration = 1}) : _recipe = FactoryMaterialModel.getRecipeFromType(craftMaterial), super(coordinates, direction, EquipmentType.crafter, tickDuration: craftingTickDuration);

  final Map<FactoryRecipeMaterialType, int> _recipe;
  FactoryMaterialType craftMaterial;

  FactoryMaterialModel _crafted;

  int getRecipeAmount(FactoryMaterialType fmt){
    return _recipe[fmt] ?? 0;
  }

  bool get canCraft{
    bool canCraft = true;
    _recipe.keys.forEach((FactoryRecipeMaterialType fmt){
      canCraft = canCraft && _recipe[fmt] <= objects.where((FactoryMaterialModel fm) => fm.type == fmt.materialType && fm.state == fmt.state).length;
    });
    return canCraft;
  }

  @override
  List<FactoryMaterialModel> tick() {
    if(tickDuration > 1 && counter % tickDuration != 1 && _crafted == null){
      print('Not ticking!');
      return <FactoryMaterialModel>[];
    }

    if((canCraft && _crafted != null) && tickDuration == 1){
      final FactoryMaterialModel _craftedMaterial = _crafted.copyWith();
      _crafted = null;
      _craft();

      _craftedMaterial.direction = direction;

      return <FactoryMaterialModel>[_craftedMaterial];
    }

    if(_crafted == null){
      _craft();
      return <FactoryMaterialModel>[];
    }

    final List<FactoryMaterialModel> _material = <FactoryMaterialModel>[]..add(_crafted);
    _crafted = null;

    _material.map((FactoryMaterialModel fm){
      fm.direction = direction;
    }).toList();

    return _material;
  }

  void changeRecipe(FactoryMaterialType fmt){
    craftMaterial = fmt;
    _recipe.clear();
    _recipe.addAll(FactoryMaterialModel.getRecipeFromType(craftMaterial));
  }

  void _craft(){
    if(canCraft){
      _recipe.keys.forEach((FactoryRecipeMaterialType fmt){
        for(int j = 0; j < _recipe[fmt]; j++){
          objects.remove(objects.firstWhere((FactoryMaterialModel fm) => fm.type == fmt.materialType && fm.state == fmt.state, orElse: () => null));
        }
      });

      _crafted = FactoryMaterialModel.getFromType(craftMaterial, offset: pointingOffset);
      _crafted.direction = direction;
    }
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    double _myProgress = ((counter % tickDuration) / tickDuration) + (progress / tickDuration);
    double _machineProgress = (counter % tickDuration) >= (tickDuration / 2) ? _myProgress : (1 - _myProgress);

    if(tickDuration == 1){
      _machineProgress = (_myProgress > 0.5) ? ((_myProgress * 2) - 1) : (1 - (_myProgress * 2));
    }

    if(!canCraft && _crafted == null){
      _machineProgress = 0.0;
    }

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
//    canvas.drawRect(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Paint()..color = Colors.grey.shade900);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)), Radius.circular(size / 2.2 / 2)), Paint()..color = Colors.grey.shade900);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4)), Radius.circular(size / 2.4 / 2)), Paint()..color = Color.lerp(Colors.red, Colors.green, _machineProgress));//_didToggle ? (_temp == isCrafting ? 1 - progress : progress) : (isCrafting ? 1 : 0)));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Radius.circular(size / 2.5 / 2)), Paint()..color = Colors.grey.shade900);

    canvas.scale(0.6);
    FactoryMaterialModel.getFromType(craftMaterial).drawMaterial(Offset.zero, canvas, progress);
//    canvas.drawCircle(Offset(size / 4, size / 4), 4.0, Paint()..color = isCrafting || canCraft ? Colors.green : Colors.red);
    canvas.restore();
  }

  @override
  void drawTrack(Offset offset, Canvas canvas, double size, double progress){
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    drawRoller(direction, canvas, size, progress);
    //    inputDirections.keys.forEach((Direction d) => drawSplitter(d, canvas, size, progress));

    canvas.restore();
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
    _paragraphBuilder.addText('${factoryMaterialToString(craftMaterial)}\n');
    _paragraphBuilder.addText('Queue: ${objects.length}');

    Paragraph _paragraph = _paragraphBuilder.build();
    _paragraph.layout(ParagraphConstraints(width: size * 2));

    canvas.drawParagraph(_paragraph, Offset(-size, size / 6));

    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress){
    double _moveX = 0.0;
    double _moveY = 0.0;

    if(_crafted == null){
      return;
    }

    switch(direction){
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

    _crafted.drawMaterial(offset + Offset(_moveX + _crafted.offsetX, _moveY + _crafted.offsetY), canvas, progress);
  }

  @override
  FactoryEquipmentModel copyWith({Coordinates coordinates, Direction direction, int tickDuration, FactoryMaterialModel craftMaterial}) {
    return Crafter(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      craftMaterial ?? this.craftMaterial,
      craftingTickDuration: tickDuration ?? this.tickDuration,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'craft_material': craftMaterial.index
    });
    return _map;
  }
}