import 'package:flutter/material.dart';
import 'package:flutter_factory/game/equipment/crafter.dart';
import 'package:flutter_factory/game/equipment/splitter.dart';
import 'package:flutter_factory/game/model/factory_equipment.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/crafter_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/splitter_options.dart';

class BuildEquipmentWidget extends StatelessWidget {
  BuildEquipmentWidget(this._bloc, {Key key}) : super(key: key);

  final GameBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360.0,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(height: 20.0,),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Build equipment:'),
                  DropdownButton<EquipmentType>(
                    onChanged: (EquipmentType et){
                      _bloc.buildSelectedEquipmentType = et;
                    },
                    value: _bloc.buildSelectedEquipmentType,
                    items: EquipmentType.values.map((EquipmentType et){
                      return DropdownMenuItem<EquipmentType>(
                        value: et,
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: CustomPaint(
                                painter: ObjectPainter(
                                  _bloc.progress,
                                  equipment: _bloc.previewEquipment(et),
                                  objectSize: 32.0
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(12.0),
                              child: Text('${et.toString().replaceAll('EquipmentType.', '').toUpperCase()}')
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Build direction:'),
                  DropdownButton<Direction>(
                    onChanged: (Direction et){
                      _bloc.buildSelectedEquipmentDirection = et;
                    },
                    value: _bloc.buildSelectedEquipmentDirection,
                    items: Direction.values.map((Direction et){
                      return DropdownMenuItem<Direction>(
                        value: et,
                        child: Container(
                          margin: const EdgeInsets.all(12.0),
                          child: Text('${et.toString().replaceAll('Direction.', '').toUpperCase()}')
                        ),
                      );
                    }).toList()
                  ),
                ],
              ),
            ],
          ),

          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            child: RaisedButton(
              color: Colors.blue,
              onPressed: _bloc.buildSelected,
              child: Text('BUILD', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
            ),
          ),

          SizedBox(height: 20.0,),
        ],
      ),
    );
  }
}
