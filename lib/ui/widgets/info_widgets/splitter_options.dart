import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';

class SplitterOptionsWidget extends StatefulWidget {
  SplitterOptionsWidget({@required this.splitter, Key key}) : super(key: key);

  final Splitter splitter;

  @override
  _SplitterOptionsWidgetState createState() => _SplitterOptionsWidgetState();
}

class _SplitterOptionsWidgetState extends State<SplitterOptionsWidget> {
  bool _addMode = true;

  Widget _buildButton(Direction d){
    return OutlineButton(
      padding: const EdgeInsets.all(8.0),
      onPressed: (){
        if(_addMode){
          widget.splitter.directions.add(d);
        }else{
          widget.splitter.directions.remove(d);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Text('${directionToString(d)}\n[${widget.splitter.directions.where((Direction _d) => _d == d).length}]', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.splitter.directions.sort((Direction d, Direction dd) => d.index.compareTo(dd.index));

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: <Color>[
            (_addMode ? DynamicTheme.of(context).data.positiveActionButtonColor : DynamicTheme.of(context).data.negativeActionButtonColor).withOpacity(0.0),
            (_addMode ? DynamicTheme.of(context).data.positiveActionButtonColor : DynamicTheme.of(context).data.negativeActionButtonColor).withOpacity(0.4),
          ],
          radius: 1.2,
        )
      ),
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildButton(Direction.south),
              SizedBox(height: 24.0,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildButton(Direction.west),
                  SizedBox(width: 12.0,),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    color: _addMode ? DynamicTheme.of(context).data.positiveActionButtonColor : DynamicTheme.of(context).data.negativeActionButtonColor,
                    child: FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: (){
                        setState(() {
                          _addMode = !_addMode;
                        });
                      },
                      child: Text(_addMode ? '+' : '-', style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w900, fontSize: 18.0),),
                    ),
                  ),
                  SizedBox(width: 12.0,),
                  _buildButton(Direction.east),
                ],
              ),
              SizedBox(height: 24.0,),
              _buildButton(Direction.north),
            ],
          ),
        ),
      ),
    );
  }
}
