import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/coordinates.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';

class GameWidget extends StatefulWidget {
  GameWidget({Key key}) : super(key: key);

  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class GameCameraPosition{
  double scale = 1.0;
  Offset position = Offset.zero;
}

class _GameWidgetState extends State<GameWidget> {
  final GameCameraPosition _gameCameraPosition = GameCameraPosition();
  final List<Coordinates> _selected = <Coordinates>[];

  GameBloc _bloc;

  double _cubeSize = 50.0;
  double _scaleEnd;
  Offset _startPoint;

  @override
  Widget build(BuildContext context) {
    _bloc = GameProvider.of(context);

    return StreamBuilder<GameUpdate>(
      stream: _bloc.gameUpdate,
      builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot){
        return GestureDetector(
          onScaleStart: (ScaleStartDetails ssd){
            _scaleEnd = _gameCameraPosition.scale;
            _startPoint = ssd.focalPoint - _gameCameraPosition.position;
          },
          onScaleUpdate: (ScaleUpdateDetails sud){
            _gameCameraPosition.scale = _scaleEnd * sud.scale;

            final Offset normalizedOffset = _startPoint / _scaleEnd;
            final Offset _offset = sud.focalPoint - normalizedOffset * _gameCameraPosition.scale;

            _gameCameraPosition.position = _offset;
          },
          onTapUp: (TapUpDetails tud){
            final Offset _s = (tud.globalPosition - _gameCameraPosition.position) / _gameCameraPosition.scale + Offset(_cubeSize / 2, _cubeSize / 2);
            final Coordinates _coordinate = Coordinates((_s.dx / _cubeSize).floor(),(_s.dy / _cubeSize).floor());

            if(_selected.contains(_coordinate)){
              _selected.remove(_coordinate);
            }else{
              if(_selected.isNotEmpty && (_bloc.equipment.firstWhere((FactoryEquipment fe) => fe.coordinates == _coordinate, orElse: () => null) != null || _bloc.equipment.firstWhere((FactoryEquipment fe) => fe.coordinates == _selected.first, orElse: () => null) != null)){
                _selected.clear();
              }

              if(_selected.isEmpty || _bloc.equipment.firstWhere((FactoryEquipment fe) => fe.coordinates == _coordinate, orElse: () => null) == null){
                if(_coordinate.x >= 0 && _coordinate.y >= 0 && _coordinate.x <= 1000 && _coordinate.y <= 1000){
                  _selected.add(_coordinate);
                }
              }
            }

            _bloc.selectedTiles = _selected;
          },
          child: CustomPaint(
            painter: GamePainter(_bloc, 100, 100, _gameCameraPosition, _cubeSize, selectedTiles: _selected),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class GamePainter extends CustomPainter{
  const GamePainter(this.bloc, this.rows, this.columns, this.camera, this.cubeSize, {this.selectedTiles, Listenable repaint}) : super(repaint: repaint);

  final int rows;
  final int columns;
  final double cubeSize;
  final GameBloc bloc;

  final List<Coordinates> selectedTiles;
  final GameCameraPosition camera;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(null, Paint());

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

    selectedTiles.forEach((Coordinates c){
      canvas.drawRect(
        Rect.fromCircle(
          center: Offset(c.x * cubeSize, c.y * cubeSize),
          radius: cubeSize / 2
        ),
        Paint()..color = Colors.orange
      );
    });

    bloc.equipment.forEach((FactoryEquipment fe){
      fe.drawTrack(Offset(fe.coordinates.x * cubeSize, fe.coordinates.y * cubeSize), canvas, cubeSize, bloc.progress);
    });

    bloc.equipment.forEach((FactoryEquipment fe){
      fe.drawMaterial(Offset(fe.coordinates.x * cubeSize, fe.coordinates.y * cubeSize), canvas, cubeSize, bloc.progress);
    });

    bloc.equipment.forEach((FactoryEquipment fe){
      fe.drawEquipment(Offset(fe.coordinates.x * cubeSize, fe.coordinates.y * cubeSize), canvas, cubeSize, bloc.progress);

      if(bloc.showArrows){
        _paintArrows(fe.coordinates.x, fe.coordinates.y, canvas, fe);
      }
    });

    bloc.getExcessMaterial.forEach((FactoryMaterial fm){
      if(bloc.getLastExcessMaterial.contains(fm)){
        fm.drawMaterial(Offset(fm.offsetX + fm.x * cubeSize, fm.offsetY + fm.y * cubeSize), canvas, bloc.progress, opacity: 1.0 - bloc.progress);
      }else{
        fm.drawMaterial(Offset(fm.offsetX + fm.x * cubeSize, fm.offsetY + fm.y * cubeSize), canvas, bloc.progress);
      }
    });

    canvas.restore();
  }

  void _paintArrows(int x, int y, Canvas canvas, FactoryEquipment equipment){
    Paint _p = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0;

    switch(equipment.direction){
      case Direction.east:{
        canvas.drawLine(
          Offset(x * cubeSize - cubeSize / 2.2, y * cubeSize),
          Offset(x * cubeSize + cubeSize / 2.2, y * cubeSize),
          _p
        );
        canvas.drawLine(
          Offset(x * cubeSize + cubeSize / 2.2, y * cubeSize),
          Offset(x * cubeSize, y * cubeSize + cubeSize / 2.5),
          _p
        );
        canvas.drawLine(
          Offset(x * cubeSize + cubeSize / 2.2, y * cubeSize),
          Offset(x * cubeSize, y * cubeSize - cubeSize / 2.5),
          _p
        );
        break;
      }
      case Direction.west:{
        canvas.drawLine(
          Offset(x * cubeSize - cubeSize / 2.2, y * cubeSize),
          Offset(x * cubeSize + cubeSize / 2.2, y * cubeSize),
          _p
        );
        canvas.drawLine(
          Offset(x * cubeSize - cubeSize / 2.2, y * cubeSize),
          Offset(x * cubeSize, y * cubeSize + cubeSize / 2.5),
          _p
        );
        canvas.drawLine(
          Offset(x * cubeSize - cubeSize / 2.2, y * cubeSize),
          Offset(x * cubeSize, y * cubeSize - cubeSize / 2.5),
          _p
        );
        break;
      }
      case Direction.south:{
        canvas.drawLine(
          Offset(x * cubeSize, y * cubeSize - cubeSize / 2.2),
          Offset(x * cubeSize, y * cubeSize + cubeSize / 2.2),
          _p
        );
        canvas.drawLine(
          Offset(x * cubeSize - cubeSize / 2.5, y * cubeSize),
          Offset(x * cubeSize, y * cubeSize - cubeSize / 2.2),
          _p
        );
        canvas.drawLine(
          Offset(x * cubeSize + cubeSize / 2.5, y * cubeSize),
          Offset(x * cubeSize, y * cubeSize - cubeSize / 2.2),
          _p
        );
        break;
      }
      case Direction.north:{
        canvas.drawLine(
          Offset(x * cubeSize, y * cubeSize - cubeSize / 2.2),
          Offset(x * cubeSize, y * cubeSize + cubeSize / 2.2),
          _p
        );
        canvas.drawLine(
          Offset(x * cubeSize - cubeSize / 2.5, y * cubeSize),
          Offset(x * cubeSize, y * cubeSize + cubeSize / 2.2),
          _p
        );
        canvas.drawLine(
          Offset(x * cubeSize + cubeSize / 2.5, y * cubeSize),
          Offset(x * cubeSize, y * cubeSize + cubeSize / 2.2),
          _p
        );
        break;
      }
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return true;
  }
}