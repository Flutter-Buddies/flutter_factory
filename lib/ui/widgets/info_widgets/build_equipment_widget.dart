import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class BuildEquipmentWidget extends StatefulWidget {
  BuildEquipmentWidget(this._bloc, {Key key, this.isChallenge = false}) : super(key: key);

  final GameBloc _bloc;
  final bool isChallenge;

  @override
  _BuildEquipmentWidgetState createState() => _BuildEquipmentWidgetState();
}

class _BuildEquipmentWidgetState extends State<BuildEquipmentWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<GameUpdate>(
        stream: widget._bloc.gameUpdate,
        builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 20.0,),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: Text('Build equipment:'),
                ),
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ExpansionPanelList(
                            expansionCallback: (int i, bool b){
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            children: <ExpansionPanel>[
                              ExpansionPanel(
                                canTapOnHeader: true,
                                isExpanded: _isExpanded,
                                headerBuilder: (BuildContext context, bool expanded){
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                    height: 100.0,
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 24.0),
                                          child: CustomPaint(
                                            painter: ObjectPainter(
                                              widget._bloc.progress,
                                              theme: DynamicTheme.of(context).data,
                                              equipment: widget._bloc.previewEquipment(widget._bloc.buildSelectedEquipmentType),
                                              objectSize: 32.0,
                                              scale: 1.6
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.0,),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                child: Text('${equipmentTypeToString(widget._bloc.buildSelectedEquipmentType)}',
                                                  style: Theme.of(context).textTheme.subtitle,
                                                )
                                              ),
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                child: Text('${equipmentDescriptionFromType(widget._bloc.buildSelectedEquipmentType)}',
                                                  style: Theme.of(context).textTheme.caption,
                                                )
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                body: Column(
                                  children: EquipmentType.values.where((EquipmentType et){
                                    if(widget.isChallenge){
                                      return et != EquipmentType.dispenser && et != EquipmentType.seller;
                                    }

                                    return true;
                                  }).map((EquipmentType et){
                                    return InkWell(
                                      onTap: (){
                                        widget._bloc.buildSelectedEquipmentType = et;

                                        setState(() {
                                          _isExpanded = false;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 250),
                                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                        foregroundDecoration: BoxDecoration(
                                          color: widget._bloc.buildSelectedEquipmentType == et ? DynamicTheme.of(context).data.neutralActionButtonColor.withOpacity(0.2) : Colors.transparent,
                                          border: widget._bloc.buildSelectedEquipmentType == et ? Border.all(color: DynamicTheme.of(context).data.neutralActionButtonColor) : null,
                                        ),
                                        decoration: BoxDecoration(
                                          color: et.index % 2 == 0 ? Colors.grey.shade200 : Colors.transparent,
                                        ),
                                        height: 80.0,
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: CustomPaint(
                                                painter: ObjectPainter(
                                                  widget._bloc.progress,
                                                  theme: DynamicTheme.of(context).data,
                                                  equipment: widget._bloc.previewEquipment(et),
                                                  objectSize: 32.0
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12.0,),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                    child: Text('${equipmentTypeToString(et)}',
                                                      style: Theme.of(context).textTheme.subtitle,
                                                    )
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                                    child: Text('${equipmentDescriptionFromType(et)}',
                                                      style: Theme.of(context).textTheme.caption,
                                                    )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Build direction:'),
                        Flexible(
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                FlatButton(
                                  padding: EdgeInsets.zero,
                                  color: widget._bloc.buildSelectedEquipmentDirection == Direction.south ? Colors.blue.shade200 : Colors.transparent,
                                  child: Text('↑', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                                  onPressed: (){
                                    widget._bloc.buildSelectedEquipmentDirection = Direction.south;
                                  },
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    FlatButton(
                                      padding: EdgeInsets.zero,
                                      color: widget._bloc.buildSelectedEquipmentDirection == Direction.west ? Colors.blue.shade200 : Colors.transparent,
                                      child: Text('←', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                                      onPressed: (){
                                          widget._bloc.buildSelectedEquipmentDirection = Direction.west;
                                      },
                                    ),
                                    FlatButton(
                                      padding: EdgeInsets.zero,
                                      color: widget._bloc.buildSelectedEquipmentDirection == Direction.east ? Colors.blue.shade200 : Colors.transparent,
                                      child: Text('→', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                                      onPressed: (){
                                          widget._bloc.buildSelectedEquipmentDirection = Direction.east;
                                      },
                                    ),
                                  ],
                                ),
                                FlatButton(
                                  padding: EdgeInsets.zero,
                                  color: widget._bloc.buildSelectedEquipmentDirection == Direction.north ? Colors.blue.shade200 : Colors.transparent,
                                  child: Text('↓', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                                  onPressed: (){
                                      widget._bloc.buildSelectedEquipmentDirection = Direction.north;
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80.0,
                  child: RaisedButton(
                    color: Colors.blue,
                    onPressed: (){
                      widget._bloc.buildSelected();
                      Navigator.pop(context);
                    },
                    child: Text('BUILD', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
                  ),
                ),

                SizedBox(height: 20.0,),
              ],
            ),
          );
        }
      ),
    );
  }
}
