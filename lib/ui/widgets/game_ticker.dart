import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';

class GameTicker extends StatelessWidget {
  GameTicker({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 200.0,
      right: 100.0,
      child: Container(
        child: StreamBuilder<GameUpdate>(
          stream: GameProvider.of(context).gameUpdate,
          builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot) {
//          return Container(
//            height: 20.0,
//            width: MediaQuery.of(context).size.width * GameProvider.of(context).progress,
//            color: Colors.black38,
//          );

            return CustomPaint(
              painter: _RoundTicker(progress: GameProvider.of(context).progress),
            );
          }
        ),
      ),
    );
  }
}

class _RoundTicker extends CustomPainter{
  _RoundTicker({Listenable repaint, this.progress}) : super(repaint: repaint);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint();

    p.color = Colors.grey.shade300;
    canvas.drawCircle(Offset(50.0, -50.0), 20.0, p);

    p.color = Colors.grey;
    canvas.drawArc(Rect.fromCircle(center: Offset(50.0, -50.0), radius: 20.0), -pi * 0.5, pi * 2 * progress, true, p);

    p.color = Colors.grey.shade600;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.0;
    canvas.drawArc(Rect.fromCircle(center: Offset(50.0, -50.0), radius: 20.0), -pi * 0.5, pi * 2, false, p);
  }

  @override
  bool shouldRepaint(_RoundTicker oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
