import 'package:flutter/material.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game_bloc.dart';

class SelectedObjectFooter extends StatelessWidget {
  const SelectedObjectFooter(this._bloc, {@required this.equipment, Key key}) : super(key: key);

  final GameBloc _bloc;
  final List<FactoryEquipmentModel> equipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: <Widget>[
          RotationWidget(equipment),
          const SizedBox(height: 28.0),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            child: RaisedButton(
              color: Colors.red,
              onPressed: () {
                equipment.where((FactoryEquipmentModel fem) => fem.isMutable).forEach(_bloc.removeEquipment);
              },
              child: Text(
                'DELETE',
                style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 28.0),
        ],
      ),
    );
  }
}

class RotationWidget extends StatelessWidget {
  const RotationWidget(this.equipment, {Key key}) : super(key: key);

  final List<FactoryEquipmentModel> equipment;

  @override
  Widget build(BuildContext context) {
    if (equipment.first.type == EquipmentType.splitter) {
      return const SizedBox.shrink();
    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text('Direction:'),
          Flexible(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    color: equipment.first.direction == Direction.south ? Colors.blue.shade200 : Colors.transparent,
                    padding: EdgeInsets.zero,
                    child: Text(
                      '↑',
                      style:
                          Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),
                    ),
                    onPressed: () {
                      equipment.where((FactoryEquipmentModel fem) => fem.isMutable).forEach((FactoryEquipmentModel fe) {
                        fe.direction = Direction.south;
                      });
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FlatButton(
                        color: equipment.first.direction == Direction.west ? Colors.blue.shade200 : Colors.transparent,
                        padding: EdgeInsets.zero,
                        child: Text(
                          '←',
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),
                        ),
                        onPressed: () {
                          equipment
                              .where((FactoryEquipmentModel fem) => fem.isMutable)
                              .forEach((FactoryEquipmentModel fe) {
                            fe.direction = Direction.west;
                          });
                        },
                      ),
                      FlatButton(
                        color: equipment.first.direction == Direction.east ? Colors.blue.shade200 : Colors.transparent,
                        padding: EdgeInsets.zero,
                        child: Text(
                          '→',
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),
                        ),
                        onPressed: () {
                          equipment
                              .where((FactoryEquipmentModel fem) => fem.isMutable)
                              .forEach((FactoryEquipmentModel fe) {
                            fe.direction = Direction.east;
                          });
                        },
                      ),
                    ],
                  ),
                  FlatButton(
                    color: equipment.first.direction == Direction.north ? Colors.blue.shade200 : Colors.transparent,
                    padding: EdgeInsets.zero,
                    child: Text(
                      '↓',
                      style:
                          Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),
                    ),
                    onPressed: () {
                      equipment.where((FactoryEquipmentModel fem) => fem.isMutable).forEach((FactoryEquipmentModel fe) {
                        fe.direction = Direction.north;
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
