import 'package:flutter/material.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class FloorsScreen extends StatelessWidget {
  FloorsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GameBloc _bloc = Provider.of<GameBloc>(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: DynamicTheme.of(context).data.menuColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox.shrink(),
          Container(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Icon(
                    Icons.chevron_left,
                    color: ThemeProvider.of(context).textColor,
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Current floor:',
                      style: Theme.of(context).textTheme.button,
                    ),
                    Text(
                      '${_bloc.floor}',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60.0,
              ),
              Divider(),
              Column(
                children: List<Widget>.generate(4, (int index) {
                  return Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _bloc.changeFloor(index);
                      },
                      child: Container(height: 80.0, child: Center(child: Text(_bloc.getFloorName(floor: index)))),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox.shrink()
        ],
      ),
    );
  }
}
