import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';

class GameWidget extends StatefulWidget {
  GameWidget({Key key}) : super(key: key);

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  final List<Coordinates> _selected = <Coordinates>[];

  int doubleTapDuration = 300;
  int _lastTap = 0;
  Coordinates _lastTapLocation;

  List<FactoryEquipmentModel> _movingEquipment = <FactoryEquipmentModel>[];
  List<FactoryEquipmentModel> _initialMovingEquipment = <FactoryEquipmentModel>[];
  bool _isMoving = false;
  Coordinates _startMovingLocation;

  GameBloc _bloc;

  double _cubeSize = 30.0;
  double _scaleEnd;
  Offset _startPoint;

  static const double _maxZoomLimit = 40.0;
  static const double _minZoomLimit = 0.25;


  @override
  Widget build(BuildContext context) {
    _bloc = GameProvider.of(context);

    return StreamBuilder<GameUpdate>(
      stream: _bloc.gameUpdate,
      builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot){
        return GestureDetector(
          onScaleStart: (ScaleStartDetails ssd){
            final Offset _s = (ssd.focalPoint - _bloc.gameCameraPosition.position) / _bloc.gameCameraPosition.scale + Offset(_cubeSize / 2, _cubeSize / 2);
            final Coordinates _coordinate = Coordinates((_s.dx / _cubeSize).floor(),(_s.dy / _cubeSize).floor());

            if(_selected.contains(_coordinate)){
              _isMoving = true;
              _movingEquipment.addAll(_selected.where((Coordinates c) => _bloc.equipment.firstWhere((FactoryEquipmentModel fe) => fe.coordinates == c && fe.isMutable, orElse: () => null) != null).map((Coordinates c) => _bloc.equipment.firstWhere((FactoryEquipmentModel fe) => fe.coordinates == c, orElse: () => null)));
              _movingEquipment.forEach((FactoryEquipmentModel fem) => _bloc.equipment.remove(fem));

              _initialMovingEquipment.addAll(_movingEquipment);
              _startMovingLocation = _coordinate;
            }else{
              _isMoving = false;
              _scaleEnd = _bloc.gameCameraPosition.scale;
              _startPoint = ssd.focalPoint - _bloc.gameCameraPosition.position;
            }
          },
          onScaleEnd: (ScaleEndDetails sed){
            if(_isMoving){
              _initialMovingEquipment.clear();

              _selected.clear();
              _movingEquipment.removeWhere((FactoryEquipmentModel fem) => fem.coordinates.x < 0 || fem.coordinates.y < 0 || fem.coordinates.x > _bloc.mapWidth || fem.coordinates.y > _bloc.mapHeight);

              _selected.addAll(_movingEquipment.map((FactoryEquipmentModel fem) => fem.coordinates));
              _bloc.equipment.removeWhere((FactoryEquipmentModel fem) => _selected.contains(fem.coordinates));

              _bloc.equipment.addAll(_movingEquipment);
              _movingEquipment.clear();

              _isMoving = false;
            }
          },
          onScaleUpdate: (ScaleUpdateDetails sud){
            final Offset _s = (sud.focalPoint - _bloc.gameCameraPosition.position) / _bloc.gameCameraPosition.scale + Offset(_cubeSize / 2, _cubeSize / 2);
            final Coordinates _coordinate = Coordinates((_s.dx / _cubeSize).floor(),(_s.dy / _cubeSize).floor());

            if(_isMoving){
              print((_coordinate - _startMovingLocation).toMap());

              _movingEquipment = _initialMovingEquipment.map((FactoryEquipmentModel fem) => fem.copyWith(coordinates: fem.coordinates + (_coordinate - _startMovingLocation))).toList();
            }else{
              _bloc.gameCameraPosition.scale = (_scaleEnd * sud.scale).clamp(_minZoomLimit, _maxZoomLimit);

              final Offset normalizedOffset = _startPoint / _scaleEnd;
              final Offset _offset = sud.focalPoint - normalizedOffset * _bloc.gameCameraPosition.scale;

              _bloc.gameCameraPosition.position = _offset;
            }
          },
          onLongPress: _selected.clear,
          onLongPressMoveUpdate: (LongPressMoveUpdateDetails lpmud){
            final Offset _s = (lpmud.globalPosition - _bloc.gameCameraPosition.position) / _bloc.gameCameraPosition.scale + Offset(_cubeSize / 2, _cubeSize / 2);
            final Coordinates _coordinate = Coordinates((_s.dx / _cubeSize).floor(),(_s.dy / _cubeSize).floor());

            if(_coordinate.x >= 0 && _coordinate.y >= 0 && _coordinate.x <= _bloc.mapWidth && _coordinate.y <= _bloc.mapHeight){
              if(!_selected.contains(_coordinate)){
                _selected.add(_coordinate);
              }
            }

            _bloc.selectedTiles = _selected;
          },
          onTapUp: (TapUpDetails tud){
            int _tapTime = DateTime.now().millisecondsSinceEpoch;

            final Offset _s = (tud.globalPosition - _bloc.gameCameraPosition.position) / _bloc.gameCameraPosition.scale + Offset(_cubeSize / 2, _cubeSize / 2);
            final Coordinates _coordinate = Coordinates((_s.dx / _cubeSize).floor(),(_s.dy / _cubeSize).floor());
            final FactoryEquipmentModel _se = _bloc.equipment.firstWhere((FactoryEquipmentModel fe) => fe.coordinates == _coordinate, orElse: () => null);

            if(_se != null && _tapTime - _lastTap < doubleTapDuration && _se.isMutable && _lastTapLocation == _coordinate && _movingEquipment.isEmpty){
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('${equipmentTypeToString(_se.type)} copied!',
                  style: Theme.of(context).textTheme.button.copyWith(color: Colors.white)
                ),
                duration: Duration(milliseconds: 350),
                behavior: SnackBarBehavior.floating,
              ));
              _selected.clear();
              _movingEquipment.add(_se);
              _bloc.equipment.remove(_se);
            }else if(_movingEquipment.isNotEmpty){
              if(_se == null && _coordinate.x >= 0 && _coordinate.y >= 0 && _coordinate.x <= _bloc.mapWidth && _coordinate.y <= _bloc.mapHeight){
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('${equipmentTypeToString(_movingEquipment.first.type)} pasted!',
                    style: Theme.of(context).textTheme.button.copyWith(color: Colors.white)
                  ),
                  duration: Duration(milliseconds: 350),
                  behavior: SnackBarBehavior.floating,
                ));
                _bloc.equipment.add(_movingEquipment.first.copyWith(coordinates: _coordinate));
                _selected.add(_coordinate);
                _tapTime = 0;
                _movingEquipment.clear();
              }else{
                String _snackbarText;
                if(_coordinate.x >= 0 && _coordinate.y >= 0 && _coordinate.x <= _bloc.mapWidth && _coordinate.y <= _bloc.mapHeight){
                  _snackbarText = 'Can\'t paste on top of existing ${equipmentTypeToString(_se.type)}!';
                }else{
                  _snackbarText = 'Can\'t paste outside of the bounderies!';
                }

                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(_snackbarText, style: Theme.of(context).textTheme.button.copyWith(color: Colors.red),),
                  duration: Duration(milliseconds: 550),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            }else if(_selected.contains(_coordinate)){
              _selected.remove(_coordinate);
            }else{
              final List<FactoryEquipmentModel> _selectedEquipment = _bloc.equipment.where((FactoryEquipmentModel fe) => _selected.contains(fe.coordinates)).toList();
              final bool _isSameEquipment = _selectedEquipment.isEmpty || (_selectedEquipment.every((FactoryEquipmentModel fe) => fe.type == _selectedEquipment.first.type) && _selectedEquipment.length == _selected.length && (_selectedEquipment.isNotEmpty && _se?.type == _selectedEquipment.first?.type));

              if(_selected.isNotEmpty && ((_selectedEquipment.isEmpty && _se != null) || (_selectedEquipment.isNotEmpty && _se == null) || !(_isSameEquipment || (_selectedEquipment.isNotEmpty && _se?.type == _selectedEquipment.first.type)))){
                _selected.clear();
              }

              if(_coordinate.x >= 0 && _coordinate.y >= 0 && _coordinate.x <= _bloc.mapWidth && _coordinate.y <= _bloc.mapHeight){
                _selected.add(_coordinate);
              }
            }

            _lastTapLocation = _coordinate;
            _lastTap = _tapTime;
            _bloc.selectedTiles = _selected;
          },
          child: CustomPaint(
            painter: GamePainter(_bloc, _bloc.mapWidth, _bloc.mapHeight, _bloc.gameCameraPosition, _cubeSize, selectedTiles: _selected, copyMaterial: _movingEquipment),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class GamePainter extends CustomPainter{
  const GamePainter(this.bloc, this.rows, this.columns, this.camera, this.cubeSize, {this.selectedTiles, this.copyMaterial, Listenable repaint}) : super(repaint: repaint);

  final int rows;
  final int columns;
  final double cubeSize;
  final GameBloc bloc;

  final List<Coordinates> selectedTiles;
  final GameCameraPosition camera;
  final List<FactoryEquipmentModel> copyMaterial;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(null, Paint());

    canvas.drawPaint(Paint()..color = Colors.black);

    final Matrix4 _transformMatrix = Matrix4.identity()
      ..translate(camera.position.dx, camera.position.dy)
      ..scale(camera.scale);

    canvas.transform(_transformMatrix.storage);

    canvas.drawRect(
      Rect.fromPoints(
        Offset(-cubeSize / 2, -cubeSize / 2),
        Offset(cubeSize * rows + cubeSize / 2, cubeSize * columns + cubeSize / 2)
      ),
      Paint()..color = Colors.grey
    );

    for(int i = 0; i < columns; i++){
      canvas.drawLine(
        Offset(-cubeSize / 2, cubeSize * i + cubeSize / 2),
        Offset(cubeSize * rows + cubeSize / 2, cubeSize * i + cubeSize / 2),
        Paint()..color = Colors.grey.shade400..strokeWidth = 0.4
      );
    }

    for(int i = 0; i < rows; i++){
      canvas.drawLine(
        Offset(cubeSize * i + cubeSize / 2, -cubeSize / 2),
        Offset(cubeSize * i + cubeSize / 2, cubeSize * columns + cubeSize / 2),
        Paint()..color = Colors.grey.shade400..strokeWidth = 0.4
      );
    }

    selectedTiles.forEach((Coordinates c){
      canvas.drawRect(
        Rect.fromCircle(
          center: Offset(c.x * cubeSize, c.y * cubeSize),
          radius: cubeSize / 2
        ),
        Paint()..color = Colors.orange
      );
    });

    bloc.equipment.forEach((FactoryEquipmentModel fe){
      fe.drawTrack(Offset(fe.coordinates.x * cubeSize, fe.coordinates.y * cubeSize), canvas, cubeSize, bloc.progress);
    });

    bloc.equipment.forEach((FactoryEquipmentModel fe){
      fe.drawMaterial(Offset(fe.coordinates.x * cubeSize, fe.coordinates.y * cubeSize), canvas, cubeSize, bloc.progress);
    });

    bloc.equipment.forEach((FactoryEquipmentModel fe){
      fe.drawEquipment(Offset(fe.coordinates.x * cubeSize, fe.coordinates.y * cubeSize), canvas, cubeSize, bloc.progress);

      if(bloc.showArrows){
        fe.paintInfo(Offset(fe.coordinates.x * cubeSize, fe.coordinates.y * cubeSize), canvas, cubeSize, bloc.progress);
      }
    });

    if(copyMaterial != null){
      copyMaterial.forEach((FactoryEquipmentModel fem){
        canvas.save();
        canvas.clipRect(Rect.fromCircle(center: Offset(fem.coordinates.x * cubeSize, fem.coordinates.y * cubeSize), radius: cubeSize / 2));
        fem.drawTrack(Offset(fem.coordinates.x * cubeSize, fem.coordinates.y * cubeSize), canvas, cubeSize, bloc.progress);
        fem.drawEquipment(Offset(fem.coordinates.x * cubeSize, fem.coordinates.y * cubeSize), canvas, cubeSize, bloc.progress);
        canvas.drawRect(Rect.fromCircle(center: Offset(fem.coordinates.x * cubeSize, fem.coordinates.y * cubeSize), radius: cubeSize / 2), Paint()..color = Colors.grey.withOpacity(0.5));
        canvas.restore();
      });
    }

    bloc.getExcessMaterial.forEach((FactoryMaterialModel fm){
      if(bloc.getLastExcessMaterial.contains(fm)){
        fm.drawMaterial(Offset(fm.offsetX + fm.x * cubeSize, fm.offsetY + fm.y * cubeSize), canvas, bloc.progress, opacity: 1.0 - bloc.progress);
      }else{
        fm.drawMaterial(Offset(fm.offsetX + fm.x * cubeSize, fm.offsetY + fm.y * cubeSize), canvas, bloc.progress);
      }
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true;
  }
}