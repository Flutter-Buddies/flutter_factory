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

class GameCameraPosition{
  double scale = 1.0;
  Offset position = Offset.zero;
}

class _GameWidgetState extends State<GameWidget> {
  final GameCameraPosition _gameCameraPosition = GameCameraPosition();
  final List<Coordinates> _selected = <Coordinates>[];

  GameBloc _bloc;

  double _cubeSize = 30.0;
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
          onLongPress: _selected.clear,
          onLongPressMoveUpdate: (LongPressMoveUpdateDetails lpmud){
            final Offset _s = (lpmud.globalPosition - _gameCameraPosition.position) / _gameCameraPosition.scale + Offset(_cubeSize / 2, _cubeSize / 2);
            final Coordinates _coordinate = Coordinates((_s.dx / _cubeSize).floor(),(_s.dy / _cubeSize).floor());

            if(_coordinate.x >= 0 && _coordinate.y >= 0 && _coordinate.x <= 32 && _coordinate.y <= 32){
              if(!_selected.contains(_coordinate)){
                _selected.add(_coordinate);
              }
            }

            _bloc.selectedTiles = _selected;
          },
          onTapUp: (TapUpDetails tud){
            final Offset _s = (tud.globalPosition - _gameCameraPosition.position) / _gameCameraPosition.scale + Offset(_cubeSize / 2, _cubeSize / 2);
            final Coordinates _coordinate = Coordinates((_s.dx / _cubeSize).floor(),(_s.dy / _cubeSize).floor());

            if(_selected.contains(_coordinate)){
              _selected.remove(_coordinate);
            }else{
              final FactoryEquipmentModel _se = _bloc.equipment.firstWhere((FactoryEquipmentModel fe) => fe.coordinates == _coordinate, orElse: () => null);
              final List<FactoryEquipmentModel> _selectedEquipment = _bloc.equipment.where((FactoryEquipmentModel fe) => _selected.contains(fe.coordinates)).toList();
              final bool _isSameEquipment = _selectedEquipment.isEmpty || (_selectedEquipment.every((FactoryEquipmentModel fe) => fe.type == _selectedEquipment.first.type) && _selectedEquipment.length == _selected.length && (_selectedEquipment.isNotEmpty && _se?.type == _selectedEquipment.first?.type));

              if(_selected.isNotEmpty && ((_selectedEquipment.isEmpty && _se != null) || (_selectedEquipment.isNotEmpty && _se == null) || !(_isSameEquipment || (_selectedEquipment.isNotEmpty && _se?.type == _selectedEquipment.first.type)))){
                _selected.clear();
              }

              if(_coordinate.x >= 0 && _coordinate.y >= 0 && _coordinate.x <= 32 && _coordinate.y <= 32){
                _selected.add(_coordinate);
              }
            }

            _bloc.selectedTiles = _selected;
          },
          child: CustomPaint(
            painter: GamePainter(_bloc, 32, 32, _gameCameraPosition, _cubeSize, selectedTiles: _selected),
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