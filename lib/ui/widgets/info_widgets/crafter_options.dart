import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_material_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';
import 'package:flutter_factory/util/utils.dart';

class CrafterOptionsWidget extends StatefulWidget {
  CrafterOptionsWidget({@required this.crafter, this.progress = 0.0, Key key}) : super(key: key);

  final List<Crafter> crafter;
  final double progress;

  @override
  _CrafterOptionsWidgetState createState() => _CrafterOptionsWidgetState();
}

class _CrafterOptionsWidgetState extends State<CrafterOptionsWidget> {
  bool _recepiesOpen = false;

  @override
  Widget build(BuildContext context) {
    Crafter _showFirst = widget.crafter.first;
    Map<FactoryRecipeMaterialType, int> _craftMaterial =
        FactoryMaterialModel.getRecipeFromType(_showFirst.craftMaterial);
    GameBloc _bloc = GameProvider.of(context);

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: ExpansionPanelList(
              expansionCallback: (int clicked, bool open) {
                setState(() {
                  _recepiesOpen = !_recepiesOpen;
                });
              },
              children: <ExpansionPanel>[
                ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      if (_showFirst.craftMaterial == null) {
                        return Container(
                          margin: const EdgeInsets.all(12.0),
                          height: 100.0,
                          child: Center(
                            child: Text('Nothing'),
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.all(12.0),
                        height: 100.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    '${factoryMaterialToString(_showFirst.craftMaterial)}',
                                    style: Theme.of(context).textTheme.subtitle,
                                  ),
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                Row(
                                  children: _craftMaterial.keys.map((FactoryRecipeMaterialType fmrt) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 6.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                height: 20.0,
                                                width: 20.0,
                                                child: CustomPaint(
                                                  painter: ObjectPainter(widget.progress,
                                                      theme: DynamicTheme.of(context).data,
                                                      material: FactoryMaterialModel.getFromType(fmrt.materialType)
                                                        ..state = fmrt.state,
                                                      objectSize: 20.0),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 4.0,
                                              ),
                                              Text(
                                                'x ${_craftMaterial[fmrt]}',
                                                style: Theme.of(context).textTheme.caption,
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${factoryMaterialToString(fmrt.materialType)}\n(${factoryMaterialStateToString(fmrt.state)})',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.caption,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            Container(
                              height: 60.0,
                              width: 60.0,
                              child: CustomPaint(
                                painter: ObjectPainter(
                                  widget.progress,
                                  theme: DynamicTheme.of(context).data,
                                  objectSize: 60.0,
                                  material: FactoryMaterialModel.getFromType(_showFirst.craftMaterial),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    body: Column(
                      children: FactoryMaterialType.values
                          .where((FactoryMaterialType fmt) => !FactoryMaterialModel.isRaw(fmt))
                          .map((FactoryMaterialType fmt) {
                        Map<FactoryRecipeMaterialType, int> _recepie = FactoryMaterialModel.getRecipeFromType(fmt);

                        return InkWell(
                          onTap: () {
                            if (_bloc.moneyManager.isRecipeUnlocked(fmt)) {
                              widget.crafter.forEach((Crafter c) {
                                c.changeRecipe(fmt);
                              });

                              setState(() {
                                _recepiesOpen = false;
                              });
                            } else {
                              if (_bloc.moneyManager.canUnlockRecipe(fmt)) {
                                _bloc.moneyManager.unlockRecipe(fmt);
                              } else {
                                print('You dont have enough money!');
                              }
                            }
                          },
                          child: Stack(
                            children: <Widget>[
                              AnimatedContainer(
                                  duration: Duration(milliseconds: 250),
                                  padding: const EdgeInsets.all(8.0),
                                  height: 90.0,
                                  foregroundDecoration: BoxDecoration(
                                      color: fmt == widget.crafter.first.craftMaterial
                                          ? DynamicTheme.of(context).data.selectedTileColor.withOpacity(0.2)
                                          : Colors.transparent,
                                      border: fmt == widget.crafter.first.craftMaterial
                                          ? Border.all(color: DynamicTheme.of(context).data.selectedTileColor)
                                          : null),
                                  decoration: BoxDecoration(
                                    color: fmt.index % 2 == 0
                                        ? Colors.transparent
                                        : DynamicTheme.of(context).data.textColor.withOpacity(0.1),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                child: Text(
                                                  '${factoryMaterialToString(fmt)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle
                                                      .copyWith(color: DynamicTheme.of(context).data.textColor),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 12.0,
                                              ),
                                              Row(
                                                children: _recepie.keys.map((FactoryRecipeMaterialType fmrt) {
                                                  return Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Container(
                                                              height: 15.0,
                                                              width: 15.0,
                                                              child: CustomPaint(
                                                                painter: ObjectPainter(
                                                                  widget.progress,
                                                                  theme: DynamicTheme.of(context).data,
                                                                  material: FactoryMaterialModel.getFromType(
                                                                      fmrt.materialType)
                                                                    ..state = fmrt.state,
                                                                  objectSize: 15.0,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 4.0,
                                                            ),
                                                            Text(
                                                              'x ${_recepie[fmrt]}',
                                                              style: Theme.of(context).textTheme.caption.copyWith(
                                                                  color: DynamicTheme.of(context).data.textColor),
                                                            )
                                                          ],
                                                        ),
                                                        Text(
                                                          '${factoryMaterialToString(fmrt.materialType)}\n(${factoryMaterialStateToString(fmrt.state)})',
                                                          textAlign: TextAlign.center,
                                                          style: Theme.of(context).textTheme.caption,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 12.0),
                                            height: 30.0,
                                            width: 30.0,
                                            child: CustomPaint(
                                              painter: ObjectPainter(widget.progress,
                                                  theme: DynamicTheme.of(context).data,
                                                  material: FactoryMaterialModel.getFromType(fmt),
                                                  objectSize: 30.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                              AnimatedCrossFade(
                                firstChild: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.4, color: DynamicTheme.of(context).data.rollerDividersColor)),
                                  height: 100.0,
                                  child: ClipRect(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                                      child: Container(
                                        color: DynamicTheme.of(context).data.floorColor.withOpacity(0.6),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                '${factoryMaterialToString(fmt)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .title
                                                    .copyWith(fontSize: 18.0, fontWeight: FontWeight.w900),
                                              ),
                                              Text(
                                                '${factoryMaterialToString(fmt)}',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme.title.copyWith(
                                                    fontSize: 12.0,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w300),
                                              ),
                                              Text(
                                                '${createDisplay(_bloc.moneyManager.costOfRecipe(fmt))}\$',
                                                style: Theme.of(context).textTheme.title.copyWith(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w900,
                                                    color: _bloc.moneyManager.canUnlockRecipe(fmt)
                                                        ? DynamicTheme.of(context).data.positiveActionButtonColor
                                                        : DynamicTheme.of(context).data.negativeActionButtonColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                secondChild: SizedBox.shrink(),
                                alignment: Alignment.center,
                                crossFadeState: _bloc.moneyManager.isRecipeUnlocked(fmt)
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: Duration(milliseconds: 250),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    canTapOnHeader: true,
                    isExpanded: _recepiesOpen)
              ],
            ),
          ),
          SizedBox(height: 28.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Craft speed:',
                  style: Theme.of(context).textTheme.button.copyWith(color: DynamicTheme.of(context).data.textColor),
                ),
                DropdownButton<int>(
                  value: _showFirst.tickDuration,
                  onChanged: (int fmt) {
                    widget.crafter.forEach((Crafter c) => c.tickDuration = fmt);
                  },
                  items: List<int>.generate(12, (int i) => i + 1).map((int fmt) {
                    return DropdownMenuItem<int>(
                      value: fmt,
                      child: Container(
                          margin: const EdgeInsets.all(12.0),
                          child: Text(
                            '$fmt',
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: DynamicTheme.of(context).data.textColor),
                          )),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          SizedBox(height: 28.0),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                height: 50.0,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Craft queue:'),
                    Text(
                      '${_showFirst.objects.length}',
                      style: Theme.of(context).textTheme.caption.copyWith(
                          color: DynamicTheme.of(context).data.textColor, fontWeight: FontWeight.w400, fontSize: 22.0),
                    ),
                  ],
                ),
              ),
              Divider(),
              Column(
                children: FactoryMaterialType.values.where((FactoryMaterialType type) {
                  return _showFirst.objects.where((FactoryMaterialModel _fm) => _fm.type == type).isNotEmpty;
                }).map((FactoryMaterialType fmt) {
                  return Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: CustomPaint(
                                    painter: ObjectPainter(widget.progress,
                                        theme: DynamicTheme.of(context).data,
                                        scale: 2.5,
                                        material: FactoryMaterialModel.getFromType(fmt)),
                                  ),
                                ),
                                Text(
                                  '${factoryMaterialToString(fmt)}',
                                  style: Theme.of(context).textTheme.caption.copyWith(
                                      color: DynamicTheme.of(context).data.textColor, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            Container(
                                child: Center(
                                    child: Text(
                              '${_showFirst.objects.where((FactoryMaterialModel _fm) => _fm.type == fmt).length}',
                              style: Theme.of(context).textTheme.caption.copyWith(
                                  fontWeight: FontWeight.w900, color: DynamicTheme.of(context).data.textColor),
                            ))),
                          ],
                        ),
                      ),
                      FactoryMaterialModel.isRaw(fmt)
                          ? Column(
                              children: FactoryMaterialState.values
                                  .where((FactoryMaterialState fms) =>
                                      fms.index < 4 &&
                                      _showFirst.objects.firstWhere(
                                              (FactoryMaterialModel fmm) => fmm.type == fmt && fmm.state == fms,
                                              orElse: () => null) !=
                                          null)
                                  .map((FactoryMaterialState states) {
                                return Container(
                                  color: states.index % 2 == 0
                                      ? DynamicTheme.of(context).data.textColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 48.0, right: 24.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            height: 20.0,
                                            width: 20.0,
                                            margin: const EdgeInsets.symmetric(horizontal: 24.0),
                                            child: CustomPaint(
                                              painter: ObjectPainter(widget.progress,
                                                  theme: DynamicTheme.of(context).data,
                                                  material: FactoryMaterialModel.getFromType(fmt)..state = states),
                                            ),
                                          ),
                                          Text(
                                            '${factoryMaterialStateToString(states)}',
                                            style: Theme.of(context).textTheme.caption.copyWith(
                                                color: DynamicTheme.of(context).data.textColor.withOpacity(0.4)),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${_showFirst.objects.where((FactoryMaterialModel _fm) => _fm.type == fmt && _fm.state == states).length}',
                                        style: Theme.of(context).textTheme.caption.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: DynamicTheme.of(context).data.textColor.withOpacity(0.4)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                          : SizedBox.shrink(),
                      Divider(),
                    ],
                  );
                }).toList(),
              )
            ],
          ),
          SizedBox(height: 28.0),
        ],
      ),
    );
  }
}
