import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/game_theme.dart';
import 'package:flutter_factory/ui/theme/themes/light_game_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:random_color/random_color.dart';

class GameWidget extends StatefulWidget {
  GameWidget({this.isPreview = false, Key key}) : super(key: key);

  final bool isPreview;
  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  GameBloc _bloc;

  @override
  Widget build(BuildContext context) {
    _bloc = GameProvider.of(context);

    if(widget.isPreview){
      return CustomPaint(
        isComplex: true,
        willChange: true,
        painter: GamePainter(_bloc, theme: ThemeProvider.of(context)),
        child: const SizedBox.expand(),
      );
    }

    return GestureDetector(
      onScaleStart: _bloc.onScaleStart,
      onScaleEnd: _bloc.onScaleEnd,
      onScaleUpdate: _bloc.onScaleUpdate,
      onLongPress: _bloc.selectedTiles.clear,
      onLongPressMoveUpdate: _bloc.onLongPressUpdate,
      onLongPressEnd: _bloc.onLongPressEnd,
      onTapUp: (TapUpDetails tud) => _bloc.onTapUp(tud, Theme.of(context), DynamicTheme.of(context).data, Scaffold.of(context).showSnackBar),
      child: StreamBuilder<GameUpdate>(
        stream: _bloc.gameUpdate,
        builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot){
          if(!_bloc.hasClaimedCredit && _bloc.idleCredit != 0){
            Future<void>.microtask(showIdleDialog);
          }

          return CustomPaint(
            isComplex: true,
            willChange: true,
            painter: GamePainter(_bloc, theme: ThemeProvider.of(context)),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }

  void showIdleDialog(){
    _bloc.hasClaimedCredit = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: Text('Idle income', style: Theme.of(context).textTheme.headline,)
              ),
              SizedBox(height: 24.0,),
              Text('Your line earned: ${(_bloc.idleCredit * 0.5).round()}\$', style: Theme.of(context).textTheme.subhead,),
              SizedBox(height: 24.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: (){
                      _bloc.claimIdleCredit(multiple: 0.5);
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}

class GamePainter extends CustomPainter{
  const GamePainter(this.bloc, {this.theme = const LightGameTheme(), Listenable repaint}) : super(repaint: repaint);

  final GameBloc bloc;
  final GameTheme theme;


  @override
  void paint(Canvas canvas, Size size) {
    final Paint _basePaint = Paint()..color = theme.voidColor;
    canvas.drawPaint(_basePaint);

    final Matrix4 _transformMatrix = Matrix4.identity()
      ..translate(bloc.gameCameraPosition.position.dx, bloc.gameCameraPosition.position.dy)
      ..scale(bloc.gameCameraPosition.scale);

    canvas.transform(_transformMatrix.storage);

    canvas.drawRect(
      Rect.fromPoints(
        Offset(-bloc.cubeSize / 2, -bloc.cubeSize / 2),
        Offset(bloc.cubeSize * bloc.mapWidth + bloc.cubeSize / 2, bloc.cubeSize * bloc.mapHeight + bloc.cubeSize / 2)
      ),
      Paint()..color = theme.floorColor
    );

    bloc.selectedTiles.forEach((Coordinates c){
      final FactoryEquipmentModel _equipment = bloc.equipment.firstWhere((FactoryEquipmentModel fe) => c.x == fe.coordinates.x && c.y == fe.coordinates.y, orElse: () => null);

      if(_equipment == null){
        canvas.drawRect(
          Rect.fromCircle(
            center: Offset(c.x * bloc.cubeSize, c.y * bloc.cubeSize),
            radius: bloc.cubeSize / 2
          ),
          Paint()..color = bloc.items.cost(bloc.buildSelectedEquipmentType) * (bloc.selectedTiles.indexOf(c) + 1) < bloc.currentCredit ? theme.selectedTileColor : theme.negativeActionButtonColor.withOpacity(0.4)
        );
        return;
      }

      canvas.drawRect(
        Rect.fromCircle(
          center: Offset(c.x * bloc.cubeSize, c.y * bloc.cubeSize),
          radius: bloc.cubeSize / 2
        ),
        Paint()..color = theme.selectedTileColor
      );
    });

    for(int i = 0; i < bloc.mapHeight; i++){
      canvas.drawLine(
        Offset(-bloc.cubeSize / 2, bloc.cubeSize * i + bloc.cubeSize / 2),
        Offset(bloc.cubeSize * bloc.mapWidth + bloc.cubeSize / 2, bloc.cubeSize * i + bloc.cubeSize / 2),
        Paint()..color = theme.separatorsColor..strokeWidth = 0.4
      );
    }

    for(int i = 0; i < bloc.mapWidth; i++){
      canvas.drawLine(
        Offset(bloc.cubeSize * i + bloc.cubeSize / 2, -bloc.cubeSize / 2),
        Offset(bloc.cubeSize * i + bloc.cubeSize / 2, bloc.cubeSize * bloc.mapHeight + bloc.cubeSize / 2),
        Paint()..color = theme.separatorsColor..strokeWidth = 0.4
      );
    }

    final List<Coordinates> _didConnect = <Coordinates>[];

    bloc.equipment.where((FactoryEquipmentModel fe) => fe is UndergroundPortal && fe.connectingPortal != null && fe.distance != null).map<UndergroundPortal>((FactoryEquipmentModel fem) => fem).forEach((UndergroundPortal up){
      if(_didConnect.contains(up.coordinates)){
        return;
      }

      if(up.coordinates.x == up.connectingPortal.x){
        final bool _goUp = up.coordinates.y > up.connectingPortal.y;

        for(int i = 0; i < (up.distance + 1); i++){
          canvas.drawRect(
            Rect.fromCircle(
              center: Offset(up.coordinates.x * bloc.cubeSize, (up.coordinates.y + (_goUp ? -i : i)) * bloc.cubeSize),
              radius: bloc.cubeSize / 2
            ),
            Paint()..color = up.lineColor.withOpacity(0.25)
          );
        }
      }else{
        final bool _goRight = up.coordinates.x > up.connectingPortal.x;

        for(int i = 0; i < (up.distance + 1); i++){
          canvas.drawRect(
            Rect.fromCircle(
              center: Offset((up.coordinates.x + (_goRight ? -i : i)) * bloc.cubeSize, up.coordinates.y * bloc.cubeSize),
              radius: bloc.cubeSize / 2
            ),
            Paint()..color = up.lineColor.withOpacity(0.25)
          );
        }
      }

      _didConnect.add(up.connectingPortal);
    });

    bloc.equipment.forEach((FactoryEquipmentModel fe){
      fe.drawTrack(theme, Offset(fe.coordinates.x * bloc.cubeSize, fe.coordinates.y * bloc.cubeSize), canvas, bloc.cubeSize, bloc.progress);
    });

    bloc.equipment.forEach((FactoryEquipmentModel fe){
      fe.drawMaterial(theme, Offset(fe.coordinates.x * bloc.cubeSize, fe.coordinates.y * bloc.cubeSize), canvas, bloc.cubeSize, bloc.progress);
    });

    bloc.equipment.forEach((FactoryEquipmentModel fe){
      fe.drawEquipment(theme, Offset(fe.coordinates.x * bloc.cubeSize, fe.coordinates.y * bloc.cubeSize), canvas, bloc.cubeSize, bloc.progress);

      if(bloc.showArrows){
        fe.paintInfo(theme, Offset(fe.coordinates.x * bloc.cubeSize, fe.coordinates.y * bloc.cubeSize), canvas, bloc.cubeSize, bloc.progress);
      }
    });

    if(bloc.movingEquipment != null){
      int totalCost = 0;

      bloc.movingEquipment.forEach((FactoryEquipmentModel fem){
        totalCost += bloc.items.cost(fem.type);

        bool _inLimits = fem.coordinates.x >= 0 && fem.coordinates.y >= 0 && fem.coordinates.x <= bloc.mapWidth && fem.coordinates.y <= bloc.mapHeight;
        bool _canAfford = totalCost < bloc.currentCredit || bloc.copyMode != CopyMode.copy;

        canvas.save();
        canvas.clipRect(Rect.fromCircle(center: Offset(fem.coordinates.x * bloc.cubeSize, fem.coordinates.y * bloc.cubeSize), radius: bloc.cubeSize / 2));
        fem.drawTrack(theme, Offset(fem.coordinates.x * bloc.cubeSize, fem.coordinates.y * bloc.cubeSize), canvas, bloc.cubeSize, bloc.progress);
        fem.drawEquipment(theme, Offset(fem.coordinates.x * bloc.cubeSize, fem.coordinates.y * bloc.cubeSize), canvas, bloc.cubeSize, bloc.progress);
        canvas.drawRect(Rect.fromCircle(center: Offset(fem.coordinates.x * bloc.cubeSize, fem.coordinates.y * bloc.cubeSize), radius: bloc.cubeSize / 2), Paint()..color = _inLimits ? theme.floorColor.withOpacity(0.5) : theme.machineInActiveColor.withOpacity(0.6));
        if(_inLimits){
          canvas.drawRect(Rect.fromCircle(center: Offset(fem.coordinates.x * bloc.cubeSize, fem.coordinates.y * bloc.cubeSize), radius: bloc.cubeSize / 2), Paint()..color = _canAfford ? theme.selectedTileColor.withOpacity(0.5) : theme.negativeActionButtonColor.withOpacity(0.5));
        }
        canvas.restore();
      });
    }

    bloc.getExcessMaterial.forEach((FactoryMaterialModel fm){
      if(bloc.getLastExcessMaterial.contains(fm)){
        fm.drawMaterial(Offset(fm.offsetX + fm.x * bloc.cubeSize, fm.offsetY + fm.y * bloc.cubeSize), canvas, bloc.progress, opacity: 1.0 - bloc.progress);
      }else{
        fm.drawMaterial(Offset(fm.offsetX + fm.x * bloc.cubeSize, fm.offsetY + fm.y * bloc.cubeSize), canvas, bloc.progress);
      }
    });
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true;
  }
}