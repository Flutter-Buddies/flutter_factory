part of factory_equipment;

class Dispenser extends FactoryEquipmentModel{
  Dispenser(Coordinates coordinates, Direction direction, this.dispenseMaterial, {this.dispenseAmount = 3, int dispenseTickDuration = 1, bool isMutable = true, this.isWorking = true}) : super(coordinates, direction, EquipmentType.dispenser, tickDuration: dispenseTickDuration, isMutable: isMutable);

  FactoryMaterialType dispenseMaterial;

  int dispenseAmount;
  List<FactoryMaterialModel> _materials = <FactoryMaterialModel>[];

  bool _didToggle = false;
  bool isWorking;

  @override
  List<FactoryMaterialModel> tick() {
    if(!isWorking){
      return <FactoryMaterialModel>[];
    }

    _didToggle = tickDuration > 1 && (counter % tickDuration == 0 || counter % tickDuration == tickDuration - 1);

    if(_materials.isNotEmpty){
      final List<FactoryMaterialModel> _fml = <FactoryMaterialModel>[]..addAll(_materials);
      _materials.clear();

      if(tickDuration == 1){
        _materials = List<FactoryMaterialModel>.generate(dispenseAmount, (int index) => _getMaterial()..direction = direction);
      }

      return _fml;
    }else if((counter - 1) % tickDuration != 0){
      return <FactoryMaterialModel>[];
    }

    _materials = List<FactoryMaterialModel>.generate(dispenseAmount, (int index) => _getMaterial()..direction = direction);

    return <FactoryMaterialModel>[];
  }

  FactoryMaterialModel _getMaterial(){
    switch(dispenseMaterial){
      case FactoryMaterialType.gold:
        return Gold.fromOffset(pointingOffset);
      case FactoryMaterialType.iron:
        return Iron.fromOffset(pointingOffset);
      case FactoryMaterialType.diamond:
        return Diamond.fromOffset(pointingOffset);
      case FactoryMaterialType.copper:
        return Copper.fromOffset(pointingOffset);
      case FactoryMaterialType.aluminium:
        return Aluminium.fromOffset(pointingOffset);
      default:
        return Iron.fromOffset(pointingOffset);
    }
  }

  @override
  void drawEquipment(Offset offset, Canvas canvas, double size, double progress) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.2, size / 2.2), Offset(-size / 2.2, -size / 2.2)), Radius.circular(size / 2.2 / 2)), Paint()..color = Colors.grey.shade200);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.4, size / 2.4), Offset(-size / 2.4, -size / 2.4)), Radius.circular(size / 2.4 / 2)), Paint()..color = Color.lerp(Colors.red, Colors.green, _didToggle ? (counter % tickDuration == tickDuration - 1 ? progress : 1 - progress) : (counter % tickDuration == 0 ? 1 : 0)));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromPoints(Offset(size / 2.5, size / 2.5), Offset(-size / 2.5, -size / 2.5)), Radius.circular(size / 2.5 / 2)), Paint()..color = Colors.grey.shade200);

    canvas.save();
    canvas.scale(0.6);
    FactoryMaterialModel.getFromType(dispenseMaterial).drawMaterial(Offset.zero, canvas, progress);
//    ParagraphBuilder _paragraphBuilder = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center));
//    _paragraphBuilder.pushStyle(TextStyle(color: Colors.black87));
//    _paragraphBuilder.addText(factoryMaterialToString(dispenseMaterial));
//
//    Paragraph _paragraph = _paragraphBuilder.build();
//    _paragraph.layout(ParagraphConstraints(width: size));
//
//    canvas.drawParagraph(_paragraph, Offset(-size / 2, size / 6));

    canvas.restore();

    canvas.restore();
  }

  @override
  void drawMaterial(Offset offset, Canvas canvas, double size, double progress){
    if(!isWorking){
      return;
    }
    
    double _moveX = 0.0;
    double _moveY = 0.0;

    if(_materials.isEmpty){
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

    _materials.forEach((FactoryMaterialModel fm){
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
    _paragraphBuilder.addText('${factoryMaterialToString(dispenseMaterial)} x ${dispenseAmount}');

    Paragraph _paragraph = _paragraphBuilder.build();
    _paragraph.layout(ParagraphConstraints(width: size * 2));

    canvas.drawParagraph(_paragraph, Offset(-size, size / 6));


    canvas.restore();
  }

  @override
  FactoryEquipmentModel copyWith({Coordinates coordinates, Direction direction, int tickDuration, FactoryMaterialType dispenseMaterial, int dispenseAmount, bool isWorking}) {
    return Dispenser(
      coordinates ?? this.coordinates,
      direction ?? this.direction,
      dispenseMaterial ?? this.dispenseMaterial,
      dispenseTickDuration: tickDuration ?? this.tickDuration,
      dispenseAmount: dispenseAmount ?? this.dispenseAmount,
      isWorking: isWorking ?? this.isWorking,
    );
  }


  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> _map = super.toMap();
    _map.addAll(<String, dynamic>{
      'dispense_material': dispenseMaterial.index,
      'dispense_amount': dispenseAmount,
//      'is_working': isWorking
    });
    return _map;
  }
}