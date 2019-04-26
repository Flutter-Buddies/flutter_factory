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
            _gameCameraPosition.position = sud.focalPoint - _startPoint;
          },
          onTapUp: (TapUpDetails tud){
            final Offset _selectedOffset = tud.globalPosition - _gameCameraPosition.position.scale(_gameCameraPosition.scale, _gameCameraPosition.scale).translate(-_cubeSize / 2, -_cubeSize / 2);
            final Coordinates _coordinate = Coordinates(_selectedOffset.dx ~/ (_cubeSize * _gameCameraPosition.scale), _selectedOffset.dy ~/ (_cubeSize * _gameCameraPosition.scale));

            if(_selected.contains(_coordinate)){
              _selected.remove(_coordinate);
            }else{
              if(_selected.isNotEmpty && _bloc.equipment.firstWhere((FactoryEquipment fe) => fe.coordinates == _selected.first, orElse: () => null) != null){
                _selected.clear();
              }

              if(_selected.isEmpty || _bloc.equipment.firstWhere((FactoryEquipment fe) => fe.coordinates == _coordinate, orElse: () => null) == null){
                _selected.add(_coordinate);
              }
            }


            _bloc.selectedTiles = _selected;
            _selected.forEach((Coordinates c) => print('X: ${c.x} / Y: ${c.y}'));
          },
          child: CustomPaint(
            painter: GamePainter(_bloc, 30, 30, _gameCameraPosition, _cubeSize, selectedTiles: _selected),
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
    canvas.save();
    canvas.scale(camera.scale, camera.scale);
    canvas.translate(camera.position.dx, camera.position.dy);

    for(int x = 0; x < rows; x++){
      for(int y = 0; y < columns; y++){
        bool _selected = !selectedTiles.indexWhere((Coordinates c) => c.x == x && c.y == y).isNegative;

        canvas.drawRect(
          Rect.fromCircle(
            center: Offset(x * cubeSize, y * cubeSize),
            radius: cubeSize / 2
          ),
          Paint()..color = _selected ? Colors.orange : Colors.grey
        );
      }
    }

    for(int x = 0; x < rows; x++){
      for(int y = 0; y < columns; y++){
        final FactoryEquipment _equipment = bloc.equipment.firstWhere((FactoryEquipment fe) => fe.coordinates.x == x && fe.coordinates.y == y, orElse: () => null);

        if(_equipment != null){
          _equipment.drawTrack(Offset(x * cubeSize, y * cubeSize), canvas, cubeSize, bloc.progress);
        }
      }
    }

    for(int x = 0; x < rows; x++){
      for(int y = 0; y < columns; y++){
        final FactoryEquipment _equipment = bloc.equipment.firstWhere((FactoryEquipment fe) => fe.coordinates.x == x && fe.coordinates.y == y, orElse: () => null);

        if(_equipment != null){
          _equipment.drawMaterial(Offset(x * cubeSize, y * cubeSize), canvas, cubeSize, bloc.progress);
        }
      }
    }

    for(int x = 0; x < rows; x++){
      for(int y = 0; y < columns; y++){
        FactoryEquipment _equipment = bloc.equipment.firstWhere((FactoryEquipment fe) => fe.coordinates.x == x && fe.coordinates.y == y, orElse: () => null);
        List<FactoryMaterial> _material = bloc.getExcessMaterial.where((FactoryMaterial fe) => fe.x.round() == x && fe.y.round() == y).toList();

        _material.forEach((FactoryMaterial fm){
          if(bloc.getLastExcessMaterial.contains(fm)){
            fm.drawMaterial(Offset(fm.offsetX + x * cubeSize, fm.offsetY + y * cubeSize), canvas, bloc.progress, opacity: 1.0 - bloc.progress);
          }else{
            fm.drawMaterial(Offset(fm.offsetX + x * cubeSize, fm.offsetY + y * cubeSize), canvas, bloc.progress);
          }
        });


        if(_equipment != null){
          _equipment.drawEquipment(Offset(x * cubeSize, y * cubeSize), canvas, cubeSize, bloc.progress);

          if(bloc.showArrows){
            _paintArrows(x, y, canvas, _equipment);
          }
        }
      }
    }

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