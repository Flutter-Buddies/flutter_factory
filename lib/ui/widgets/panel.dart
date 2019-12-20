import 'package:flutter/material.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';

class Panel extends StatefulWidget {
  Panel(this.header, this.child, this.controller, {Key key}) : super(key: key);

  final Widget header;
  final Widget child;
  final PanelController controller;

  @override
  _PanelState createState()=> _PanelState();
}

class _PanelState extends State<Panel>{

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget child){
        return Stack(
          children: <Widget>[
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.2 + ((MediaQuery.of(context).size.height * 0.8) - (MediaQuery.of(context).size.height * 0.8) * widget.controller.value),
              child: InkWell(
                onTap: (){
                  if(widget.controller.state == PanelState.expanded){
                    widget.controller.collapse();
                  }else{
                    widget.controller.expand();
                  }
                },
                child: Container(
                  color: DynamicTheme.of(context).data.menuColor,
                  child: Stack(
                    children: <Widget>[
                      widget.header,
                      Positioned.fill(
                        top: (MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.2)) * 0.2,
                        child: IgnorePointer(
                          ignoring: widget.controller.state != PanelState.expanded,
                          child: Opacity(
                            opacity: widget.controller.value < 0.2 ? 0.0 : map(widget.controller.value, 0.2, 1.0, 0.0, 1.0),
                            child: widget.child,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  num map(num value, [num iStart = 0, num iEnd = 1.0, num oStart = 0, num oEnd = 1.0]) =>
    ((oEnd - oStart) / (iEnd - iStart)) * (value - iStart) + oStart;
}


class PanelController extends AnimationController{
  PanelController({
    double value,
    Duration duration,
    Duration reverseDuration,
    String debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    @required TickerProvider vsync,
  }) : super(
    value: value,
    duration: duration,
    reverseDuration: reverseDuration,
    debugLabel: debugLabel,
    lowerBound: lowerBound,
    upperBound: upperBound,
    animationBehavior: animationBehavior,
    vsync: vsync
  );
  
  PanelState state;

  void close(){
    state = PanelState.closed;
    animateTo(0.0);
  }

  void collapse(){
    state = PanelState.collapsed;
    animateTo(0.2);
  }

  void expand(){
    state = PanelState.expanded;
    animateTo(1.0);
  }
}

enum PanelState{
  closed, collapsed, expanded
}