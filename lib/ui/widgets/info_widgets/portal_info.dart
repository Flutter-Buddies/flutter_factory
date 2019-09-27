import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';

class PortalInfo extends StatelessWidget {
  PortalInfo({Key key, @required this.equipment, this.connectingPortal}) : super(key: key);

  final UndergroundPortal equipment;
  final UndergroundPortal connectingPortal;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: 24.0,),

          connectingPortal == null ? SizedBox.shrink() : Container(
            margin: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Input:'),

                equipment.coordinates.y == equipment.connectingPortal.y ? Row(
                  children: <Widget>[
                    RaisedButton(
                      child: Icon(Icons.chevron_left),
                      onPressed: (){
                        if(equipment.coordinates.x < connectingPortal.coordinates.x){
                          equipment.isReceiver = true;
                          connectingPortal.isReceiver = false;
                        }else{
                          equipment.isReceiver = false;
                          connectingPortal.isReceiver = true;
                        }
                      },
                    ),
                    RaisedButton(
                      child: Icon(Icons.chevron_right),
                      onPressed: (){
                        if(equipment.coordinates.x > connectingPortal.coordinates.x){
                          equipment.isReceiver = true;
                          connectingPortal.isReceiver = false;
                        }else{
                          equipment.isReceiver = false;
                          connectingPortal.isReceiver = true;
                        }},
                    ),
                  ],
                ) : Row(
                  children: <Widget>[
                    RaisedButton(
                      child: Icon(Icons.keyboard_arrow_up),
                      onPressed: (){
                        if(equipment.coordinates.y < connectingPortal.coordinates.y){
                          equipment.isReceiver = true;
                          connectingPortal.isReceiver = false;
                        }else{
                          equipment.isReceiver = false;
                          connectingPortal.isReceiver = true;
                        }
                      },
                    ),
                    RaisedButton(
                      child: Icon(Icons.keyboard_arrow_down),
                      onPressed: (){
                        if(equipment.coordinates.y > connectingPortal.coordinates.y){
                          equipment.isReceiver = true;
                          connectingPortal.isReceiver = false;
                        }else{
                          equipment.isReceiver = false;
                          connectingPortal.isReceiver = true;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          equipment.isMutable ? SizedBox.shrink() : Column(
            children: <Widget>[
              SizedBox(height: 36.0),
              Text('This ${equipmentTypeToString(equipment.type)} is part of the challenge and cannot be moved, modified or rotated!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption.copyWith(color: Colors.red, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 12.0),
            ],
          ),
        ],
      ),
    );
  }
}
