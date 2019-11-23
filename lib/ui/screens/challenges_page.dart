import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_ticker.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/build_equipment_widget.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/crafter_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/dispenser_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/selected_object_footer.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/selected_object_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/seller_info.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/sorter_options.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/splitter_options.dart';
import 'package:flutter_factory/ui/widgets/slide_game_panel.dart';
import 'package:hive/hive.dart';

class ChallengesListPage extends StatelessWidget {
  ChallengesListPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (BuildContext context, int i){
                return Divider(height: 0.0);
              },
              itemBuilder: (BuildContext context, int i){
                return Container(
                  height: 120.0,
                  child: Stack(
                    children: <Widget>[
                      FutureBuilder<Box>(
                        future: Hive.openBox<dynamic>('challenge_$i'),
                        builder: (BuildContext context, AsyncSnapshot<Box> snapshot) {
                          return Positioned(
                            right: 0.0,
                            child: Container(
                              height: 120.0,
                              width: 12.0,
                              color: !snapshot.hasData ? Colors.grey : (snapshot.data?.get('did_complete') ?? false) ? Colors.green : Colors.yellow,
                            ),
                          );
                        }
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: ListTile(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute<void>(
                              builder: (BuildContext context) => ChallengesPage(loadChallenge: i,)
                            ));
                          },
                          title: Text('Challenge ${i + 1}',
                            style: Theme.of(context).textTheme.title,
                          ),
                          subtitle: Text('You have to use the space given to you, and build production line that will output ${
                            i == 0 ? '2 Washing machines' :
                            i == 1 ? '1 Air conditioner' :
                            i == 2 ? '1 Light bulb' :
                            i == 3 ? '1 Engine' : '0.6 Railway'
                          } per tick.',
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Text('All challenges were designed by Elomavi on Discord!')
        ],
      ),
    );
  }
}

class ChallengesPage extends StatefulWidget {
  ChallengesPage({Key key, this.loadChallenge = 0}) : super(key: key);

  int loadChallenge;

  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> with SingleTickerProviderStateMixin{
  ChallengesBloc _bloc;
  GlobalKey<ScaffoldState> _key = GlobalKey();


   @override
   void dispose(){
     _bloc.dispose();
     super.dispose();
   }

  Widget _showSettings(){
    Color _textColor = DynamicTheme.of(context).data.textColor;

    return Container(
      padding: const EdgeInsets.all(12.0),
      width: MediaQuery.of(context).size.width * 0.8,
      color: ThemeProvider.of(context).menuColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(height: 40.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                backgroundColor:  DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: _bloc.increaseGameSpeed,
                child: Icon(Icons.chevron_left, color:  DynamicTheme.of(context).data.neutralActionIconColor,),
              ),
              Text('Tick speed: ${_bloc.gameSpeed} ms', style: Theme.of(context).textTheme.subtitle.copyWith(color: _textColor)),
              FloatingActionButton(
                backgroundColor:  DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: _bloc.decreaseGameSpeed,
                child: Icon(Icons.chevron_right, color:  DynamicTheme.of(context).data.neutralActionIconColor,),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Show arrows', style: Theme.of(context).textTheme.subtitle.copyWith(color: _textColor),),
            subtitle: Text('Visual representation on equipment', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor),),
            onChanged: (bool value){
              setState(() {
                _bloc.showArrows = value;
              });
            },
            value: _bloc.showArrows,
          ),

          SizedBox(height: 24.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Select type:', style: Theme.of(context).textTheme.button.copyWith(color: _textColor),),
              Stack(
                children: <Widget>[
                  DropdownButton<SelectMode>(
                    onChanged: (SelectMode tt){
                      _bloc.selectMode = tt;
                    },
                    style: Theme.of(context).textTheme.button.copyWith(color: _textColor),
                    value: _bloc.selectMode,
                    items: SelectMode.values.map((SelectMode tt){
                      TextStyle _style = Theme.of(context).textTheme.button;

                      return DropdownMenuItem<SelectMode>(
                        value: tt,
                        child: Text(tt.toString(),
                          style: _style,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),

          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60.0,
                child: RaisedButton(
                  color:  DynamicTheme.of(context).data.positiveActionButtonColor,
                  onPressed: (){
                    _bloc.equipment.where((FactoryEquipmentModel fem) => fem is Dispenser).map<Dispenser>((FactoryEquipmentModel fem) => fem).forEach((Dispenser d){
                      d.isWorking = true;
                    });
                  },
                  child: Text('Turn on all dispensers', style: Theme.of(context).textTheme.subhead.copyWith(color:  DynamicTheme.of(context).data.positiveActionIconColor),),
                ),
              ),
              SizedBox(height: 8.0,),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 60.0,
                child: RaisedButton(
                  color:  DynamicTheme.of(context).data.negativeActionButtonColor,
                  onPressed: (){
                    _bloc.equipment.where((FactoryEquipmentModel fem) => fem is Dispenser).map<Dispenser>((FactoryEquipmentModel fem) => fem).forEach((Dispenser d){
                      d.isWorking = false;
                    });
                  },
                  child: Text('Turn off all dispensers', style: Theme.of(context).textTheme.subhead.copyWith(color:  DynamicTheme.of(context).data.negativeActionIconColor),),
                ),
              ),

              SizedBox(height: 24.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Theme:', style: Theme.of(context).textTheme.button.copyWith(color: _textColor),),
                  Stack(
                    children: <Widget>[
                      DropdownButton<ThemeType>(
                        onChanged: (ThemeType tt){
                          DynamicTheme.of(context).setThemeType(tt);
                        },
                        style: Theme.of(context).textTheme.button.copyWith(color: _textColor),
                        value: DynamicTheme.of(context).data.type,
                        items: ThemeType.values.map((ThemeType tt){
                          TextStyle _style = Theme.of(context).textTheme.button;

                          return DropdownMenuItem<ThemeType>(
                            value: tt,
                            child: Text(getThemeName(tt),
                              style: _style,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text('Machines: ${_bloc.equipment.length}', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                Text('Materials: ${_bloc.material.length}', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                Text('Excess Materials: ${_bloc.getExcessMaterial.length}', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
                Text('FPT: ${_bloc.frameRate}', style: Theme.of(context).textTheme.caption.copyWith(color: _textColor, fontSize: 18.0, fontWeight: FontWeight.w300)),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            child: FlatButton(
              onPressed: (){
                _bloc.equipment.forEach((FactoryEquipmentModel fem){
                  fem.objects.clear();
                });
              },
              child: Text('Vaporize all material on this floor', style: Theme.of(context).textTheme.subhead.copyWith(color:  DynamicTheme.of(context).data.negativeActionButtonColor, fontWeight: FontWeight.w400),),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            child: RaisedButton(
              color: Colors.red,
              onPressed: () async {
                bool _clear = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text('Clear?'),
                      content: Text('Are you sure you want to restart this challenge?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('CLEAR', style: Theme.of(context).textTheme.button.copyWith(color: DynamicTheme.of(context).data.negativeActionButtonColor),),
                          onPressed: (){
                            Navigator.pop(context, true);
                          },
                        ),

                        SizedBox(width: 12.0,),

                        FlatButton(
                          child: Text('CANCEL'),
                          onPressed: (){
                            Navigator.pop(context, false);
                          },
                        ),
                      ],
                    );
                  }
                ) ?? false;

                if(_clear){
                  _bloc.restart();
                }
              },
              child: Text('Restart challenge', style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    _bloc ??= ChallengesBloc(widget.loadChallenge);

    return StreamBuilder<GameUpdate>(
      stream: _bloc.gameUpdate,
      builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot){
        return Scaffold(
          key: _key,
          endDrawer: _showSettings(),
          body: GameProvider(
            bloc: _bloc,
            child: Stack(
              children: <Widget>[
                GameWidget(),
                SlideGamePanel(),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.black38,
                    child: Text('${_bloc.frameRate}',
                      style: Theme.of(context).textTheme.headline.copyWith(color: Colors.white, fontWeight: FontWeight.w200),
                    ),
                  ),
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Stack(
                      children: <Widget>[
                        AnimatedContainer(
                          duration: Duration(milliseconds: _bloc.gameSpeed),
                          curve: Curves.easeOutCubic,
                          color: Color.lerp(Colors.red, Colors.green, _bloc.complete).withOpacity(_bloc.complete == 1.0 ? 0.9 : 0.6),
                          height: 110.0,
                          width: MediaQuery.of(context).size.width * _bloc.complete,
                        ),
                        Container(
                          height: 110.0,
                          color: Colors.black38,
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          InkWell(
                                            onTap: (){
                                              Navigator.pop(context);
                                            },
                                            child: Icon(Icons.arrow_back_ios,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Column(
                                            children: <Widget>[
                                              Text(_bloc.floor,
                                                style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
                                              ),
                                              Text(_bloc.getChallengeGoalDescription(),
                                                style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),
                                              ),
                                              Text('Current production: ${(_bloc.complete * _bloc.challengeGoal.values.first).toStringAsFixed(2)}',
                                                style: Theme.of(context).textTheme.caption.copyWith(color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: (){
                                              _key.currentState.openEndDrawer();
                                            },
                                            child: Icon(Icons.settings,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: MediaQuery.of(context).size.width  * _bloc.progress,
                                  height: 4.0,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}