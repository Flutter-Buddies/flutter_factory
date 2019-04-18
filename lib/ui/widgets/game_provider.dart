import 'package:flutter/material.dart';
import 'package:flutter_factory/game_bloc.dart';

class GameProvider extends InheritedWidget {
  const GameProvider({Key key, @required Widget child, this.bloc})  : assert(child != null), super(key: key, child: child);

  final GameBloc bloc;

  static GameBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(GameProvider) as GameProvider).bloc;
  }

  @override
  bool updateShouldNotify(GameProvider oldWidget) {
    return oldWidget.bloc != bloc;
  }
}