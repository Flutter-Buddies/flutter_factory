import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_factory/challanges_bloc.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/game_bloc.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/info_widgets/object_painter.dart';
import 'package:flutter_factory/util/utils.dart';

class BuildEquipmentWidget extends StatefulWidget {
  const BuildEquipmentWidget(this._bloc, {Key key}) : super(key: key);

  final GameBloc _bloc;

  @override
  _BuildEquipmentWidgetState createState() => _BuildEquipmentWidgetState();
}

class _BuildEquipmentWidgetState extends State<BuildEquipmentWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: DynamicTheme.of(context).data.voidColor,
      child: Column(
        children: EquipmentType.values.where((EquipmentType et) {
          if (widget._bloc is ChallengesBloc) {
            return et != EquipmentType.dispenser && et != EquipmentType.seller;
          }

          return true;
        }).map((EquipmentType et) {
          return InkWell(
            onTap: () {
              if (widget._bloc.moneyManager.isEquipmentUnlocked(et)) {
                widget._bloc.buildSelectedEquipmentType = et;
              } else {
                if (widget._bloc.moneyManager.canUnlockEquipment(et)) {
                  widget._bloc.moneyManager.unlockEquipment(et);
                } else {
                  print('You dont have enough money!');
                }
              }
            },
            child: Stack(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  foregroundDecoration: BoxDecoration(
                    color: widget._bloc.buildSelectedEquipmentType == et
                        ? DynamicTheme.of(context).data.selectedTileColor.withOpacity(0.2)
                        : Colors.transparent,
                    border: widget._bloc.buildSelectedEquipmentType == et
                        ? Border.all(color: DynamicTheme.of(context).data.selectedTileColor)
                        : null,
                  ),
                  decoration: BoxDecoration(
                    color: et.index % 2 == 0
                        ? DynamicTheme.of(context).data.textColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  height: 100.0,
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 32.0,
                        width: 32.0,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CustomPaint(
                          painter: ObjectPainter(widget._bloc.progress,
                              theme: DynamicTheme.of(context).data,
                              equipment: widget._bloc.previewEquipment(et),
                              objectSize: 32.0),
                        ),
                      ),
                      const SizedBox(
                        width: 12.0,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '${equipmentTypeToString(et)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(fontSize: 18.0, fontWeight: FontWeight.w900),
                                ),
                                Text('${widget._bloc.moneyManager.costOfEquipment(et)}\$',
                                    style: Theme.of(context).textTheme.headline6.copyWith(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w900,
                                        color: widget._bloc.moneyManager.canPurchaseEquipment(et)
                                            ? DynamicTheme.of(context).data.positiveActionButtonColor
                                            : DynamicTheme.of(context).data.negativeActionButtonColor))
                              ],
                            ),
                            Text(
                              '${equipmentDescriptionFromType(et)}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontSize: 12.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
                            ),
                            Text(
                              'Operating cost: ${widget._bloc.machineOperatingCost(et)}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontSize: 12.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.4, color: DynamicTheme.of(context).data.rollerDividersColor)),
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
                                  '${equipmentTypeToString(et)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(fontSize: 18.0, fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  '${equipmentDescriptionFromType(et)}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline6.copyWith(
                                      fontSize: 12.0, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  '${createDisplay(widget._bloc.moneyManager.costOfUnlockingEquipment(et))}\$',
                                  style: Theme.of(context).textTheme.headline6.copyWith(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w900,
                                      color: widget._bloc.moneyManager.canUnlockEquipment(et)
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
                  secondChild: const SizedBox.shrink(),
                  alignment: Alignment.center,
                  crossFadeState: widget._bloc.moneyManager.isEquipmentUnlocked(et)
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BuildEquipmentHeaderWidget extends StatefulWidget {
  const BuildEquipmentHeaderWidget({Key key, this.isChallenge = false}) : super(key: key);

  final bool isChallenge;

  @override
  _BuildEquipmentHeaderWidgetState createState() => _BuildEquipmentHeaderWidgetState();
}

class _BuildEquipmentHeaderWidgetState extends State<BuildEquipmentHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: RaisedButton(
                color: DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: () {
                  GameProvider.of(context).buildSelectedEquipmentDirection = Direction.values[
                      (GameProvider.of(context).buildSelectedEquipmentDirection.index + 1) % Direction.values.length];
                },
                child: Icon(
                  Icons.rotate_right,
                  color: DynamicTheme.of(context).data.neutralActionIconColor,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              color: DynamicTheme.of(context).data.floorColor,
              child: Container(
                margin: const EdgeInsets.only(left: 24.0, right: 24.0),
                height: 48.0,
                width: 48.0,
                child: Center(
                  child: CustomPaint(
                    child: Container(
                      height: 48.0,
                      width: 48.0,
                    ),
                    painter: ObjectPainter(
                      GameProvider.of(context).progress,
                      theme: DynamicTheme.of(context).data,
                      equipment: GameProvider.of(context)
                          .previewEquipment(GameProvider.of(context).buildSelectedEquipmentType),
                      objectSize: 48.0,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: RaisedButton(
                color: DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: () {
                  GameProvider.of(context).buildSelectedEquipmentDirection = Direction.values[
                      (GameProvider.of(context).buildSelectedEquipmentDirection.index - 1) % Direction.values.length];
                },
                child: Icon(
                  Icons.rotate_left,
                  color: DynamicTheme.of(context).data.neutralActionIconColor,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: RaisedButton(
              color: DynamicTheme.of(context).data.positiveActionButtonColor,
              disabledColor: DynamicTheme.of(context).data.negativeActionButtonColor,
              onPressed: GameProvider.of(context).moneyManager.canPurchaseEquipment(
                      GameProvider.of(context).buildSelectedEquipmentType,
                      bulkBuy: GameProvider.of(context).selectedTiles.length)
                  ? () {
                      GameProvider.of(context).buildSelected();
                    }
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'BUILD',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(color: DynamicTheme.of(context).data.positiveActionIconColor),
                  ),
                  Text(
                      '(${GameProvider.of(context).moneyManager.costOfEquipment(GameProvider.of(context).buildSelectedEquipmentType) * GameProvider.of(context).selectedTiles.length}\$)',
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: GameProvider.of(context).moneyManager.canPurchaseEquipment(
                                  GameProvider.of(context).buildSelectedEquipmentType,
                                  bulkBuy: GameProvider.of(context).selectedTiles.length)
                              ? DynamicTheme.of(context).data.positiveActionIconColor
                              : DynamicTheme.of(context).data.negativeActionIconColor)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
