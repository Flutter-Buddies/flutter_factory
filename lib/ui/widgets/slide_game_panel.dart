import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/panel.dart';

import '../../game_bloc.dart';
import 'info_widgets/build_equipment_widget.dart';
import 'info_widgets/crafter_options.dart';
import 'info_widgets/dispenser_options.dart';
import 'info_widgets/free_roller_info.dart';
import 'info_widgets/object_painter.dart';
import 'info_widgets/portal_info.dart';
import 'info_widgets/selected_object_footer.dart';
import 'info_widgets/selected_object_info.dart';
import 'info_widgets/seller_info.dart';
import 'info_widgets/sorter_options.dart';
import 'info_widgets/splitter_options.dart';

class SlideGamePanel extends StatefulWidget {
  const SlideGamePanel({Key key}) : super(key: key);

  @override
  _SlideGamePanelState createState() => new _SlideGamePanelState();
}

class _SlideGamePanelState extends State<SlideGamePanel> with SingleTickerProviderStateMixin {
  PanelController pc;
  GameBloc _bloc;
  EquipmentType et;

  @override
  void initState() {
    super.initState();

    pc = PanelController(vsync: this, duration: const Duration(milliseconds: 350));
  }

  @override
  Widget build(BuildContext context) {
    _bloc ??= GameProvider.of(context);

    return StreamBuilder<GameUpdate>(
        stream: _bloc.gameUpdate,
        builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot) {
          if (snapshot.hasData) {
            if (et == null || et != _bloc.buildSelectedEquipmentType) {
              et = _bloc.buildSelectedEquipmentType;
              pc.collapse();
            }

            if (_bloc.selectedTiles.isEmpty) {
              pc.close();
            } else if (pc.state == PanelState.closed) {
              pc.collapse();
            }
          }

          return Panel(
              Container(
                height: (MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.2)) * 0.2,
                child: ShowAction(bloc: _bloc),
              ),
              SingleChildScrollView(child: InfoWindow(_bloc)),
              pc);
        });
  }

  @override
  void dispose() {
//    pc.close();
    _bloc.dispose();

    super.dispose();
  }
}

class InfoWindow extends StatelessWidget {
  const InfoWindow(this._bloc, {Key key}) : super(key: key);

  final GameBloc _bloc;

  @override
  Widget build(BuildContext context) {
    if (_bloc.selectedTiles.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> _options = <Widget>[];
    final List<FactoryEquipmentModel> _selectedEquipment =
        _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList();

    if (_bloc.selectedTiles.length > 1 && _selectedEquipment.isNotEmpty && !_bloc.isSameEquipment) {
      return Container();
    }

    final FactoryEquipmentModel _equipment = _bloc.equipment.firstWhere(
        (FactoryEquipmentModel fe) =>
            _bloc.selectedTiles.first.x == fe.coordinates.x && _bloc.selectedTiles.first.y == fe.coordinates.y,
        orElse: () => null);

    Widget _buildNoEquipment() {
      return BuildEquipmentWidget(_bloc);
    }

    Widget _showSellerOptions() {
      return SellerInfo(equipment: _equipment);
    }

    Widget _showSelectedInfo() {
      return SelectedObjectInfoWidget(equipment: _equipment, progress: _bloc.progress);
    }

    Widget _showDispenserOptions() {
      return DispenserOptionsWidget(
          dispenser: _selectedEquipment
              .where((FactoryEquipmentModel fe) => fe is Dispenser)
              .map<Dispenser>((FactoryEquipmentModel fe) => fe)
              .toList(),
          progress: _bloc.progress);
    }

    Widget _showSplitterOptions() {
      return SplitterOptionsWidget(splitter: _equipment);
    }

    Widget _showSorterOptions() {
      return SorterOptionsWidget(sorter: _equipment);
    }

    Widget _showCrafterOptions() {
      return CrafterOptionsWidget(
          crafter: _selectedEquipment
              .where((FactoryEquipmentModel fe) => fe is Crafter)
              .map<Crafter>((FactoryEquipmentModel fe) => fe)
              .toList(),
          progress: _bloc.progress);
    }

    Widget _showRotationOptions() {
      return SelectedObjectFooter(_bloc, equipment: _selectedEquipment);
    }

    if (_equipment == null) {
      return _buildNoEquipment();
    }

    _options.add(_showSelectedInfo());

    switch (_equipment.type) {
      case EquipmentType.dispenser:
        _options.add(_showDispenserOptions());
        break;
      case EquipmentType.roller:
        break;
      case EquipmentType.crafter:
        _options.add(_showCrafterOptions());
        break;
      case EquipmentType.splitter:
        _options.add(_showSplitterOptions());
        break;
      case EquipmentType.sorter:
        _options.add(_showSorterOptions());
        break;
      case EquipmentType.seller:
        _options.add(_showSellerOptions());
        break;
      case EquipmentType.hydraulic_press:
        break;
      case EquipmentType.wire_bender:
        break;
      case EquipmentType.cutter:
        break;
      case EquipmentType.melter:
        break;
      case EquipmentType.freeRoller:
        break;
      case EquipmentType.rotatingFreeRoller:
        _options.add(FreeRollerInfo(equipment: _equipment));
        break;
      case EquipmentType.portal:
        _options.add(PortalInfo(
          equipment: _equipment,
          connectingPortal: _bloc.equipment.firstWhere(
              (FactoryEquipmentModel fem) =>
                  _equipment is UndergroundPortal && fem.coordinates == _equipment.connectingPortal,
              orElse: () => null),
        ));
        break;
    }

    if (_equipment.isMutable) {
      _options.add(_showRotationOptions());
    }

    return Container(
      color: ThemeProvider.of(context).menuColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: _options,
      ),
    );
  }
}

class ShowAction extends StatelessWidget {
  const ShowAction({Key key, this.bloc}) : super(key: key);

  final GameBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (bloc.selectedTiles.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<FactoryEquipmentModel> _selectedEquipment =
        bloc.equipment.where((FactoryEquipmentModel fe) => bloc.selectedTiles.contains(fe.coordinates)).toList();
    _selectedEquipment.addAll(bloc.movingEquipment);

    final FactoryEquipmentModel _equipment = _selectedEquipment.isEmpty ? null : _selectedEquipment.first;
    final bool _isNotRotatable = _equipment != null &&
        (!_equipment.isMutable ||
            (_equipment.type == EquipmentType.portal ||
                _equipment.type == EquipmentType.seller ||
                _equipment.type == EquipmentType.freeRoller ||
                _equipment.type == EquipmentType.rotatingFreeRoller));

    if (_equipment == null) {
      return const BuildEquipmentHeaderWidget();
    } else {
      final Widget _showRotate = !_isNotRotatable
          ? Container(
              child: Row(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: 60.0,
                    child: RaisedButton(
                      color: DynamicTheme.of(context).data.neutralActionButtonColor,
                      onPressed: () {
                        void _rotateEquipment(FactoryEquipmentModel fem) {
                          fem.direction = Direction.values[(fem.direction.index + 1) % Direction.values.length];
                        }

                        _selectedEquipment.forEach(_rotateEquipment);
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
                            equipment: _selectedEquipment.first,
                            objectSize: 48.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 60.0,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: RaisedButton(
                      color: DynamicTheme.of(context).data.neutralActionButtonColor,
                      onPressed: () {
                        void _rotateEquipment(FactoryEquipmentModel fem) {
                          fem.direction = Direction.values[(fem.direction.index - 1) % Direction.values.length];
                        }

                        _selectedEquipment.forEach(_rotateEquipment);
                      },
                      child: Icon(
                        Icons.rotate_left,
                        color: DynamicTheme.of(context).data.neutralActionIconColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _isNotRotatable
              ? Container(
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
                          equipment: _selectedEquipment.first,
                          objectSize: 48.0,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          _showRotate,
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: RaisedButton(
              color: DynamicTheme.of(context).data.neutralActionButtonColor,
              onPressed: () {
                bloc.copyMode = bloc.copyMode == CopyMode.move ? CopyMode.copy : CopyMode.move;
              },
              child: Icon(
                (bloc.copyMode == CopyMode.move) ? Icons.content_cut : Icons.content_copy,
                color: DynamicTheme.of(context).data.neutralActionIconColor,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: RaisedButton(
                color: DynamicTheme.of(context).data.negativeActionButtonColor,
                onPressed: () {
                  bloc.equipment
                      .where((FactoryEquipmentModel fe) => bloc.selectedTiles.contains(fe.coordinates) && fe.isMutable)
                      .toList()
                      .forEach(bloc.removeEquipment);

                  if (bloc.selectedTiles.length > 1) {
                    bloc.selectedTiles.clear();
                  }
                },
                child: Icon(
                  Icons.clear,
                  color: DynamicTheme.of(context).data.negativeActionIconColor,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
