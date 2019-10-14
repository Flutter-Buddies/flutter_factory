import 'package:flutter/material.dart';
import 'package:flutter_factory/game/factory_equipment.dart';
import 'package:flutter_factory/game/model/factory_equipment_model.dart';
import 'package:flutter_factory/ui/screens/main_page.dart';
import 'package:flutter_factory/ui/theme/dynamic_theme.dart';
import 'package:flutter_factory/ui/theme/theme_provider.dart';
import 'package:flutter_factory/ui/widgets/game_provider.dart';
import 'package:flutter_factory/ui/widgets/game_widget.dart';
import 'package:sliding_panel/sliding_panel.dart';

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
  SlideGamePanel({Key key}) : super(key: key);

  @override
  _SlideGamePanelState createState() => new _SlideGamePanelState();
}

class _SlideGamePanelState extends State<SlideGamePanel> {
  PanelController pc;
  GameBloc _bloc;
  EquipmentType et;

  bool _draggable = true;

  @override
  void initState() {
    super.initState();

    pc = PanelController();
  }

  @override
  Widget build(BuildContext context) {
    _bloc ??= GameProvider.of(context);

    return StreamBuilder<GameUpdate>(
      stream: _bloc.gameUpdate,
      builder: (BuildContext context, AsyncSnapshot<GameUpdate> snapshot) {
        if(snapshot.hasData){
          if(et == null || et != _bloc.buildSelectedEquipmentType){
            et = _bloc.buildSelectedEquipmentType;
            pc.collapse();
          }

          if(_bloc.selectedTiles.isEmpty){
            pc.close();
          }else if(pc.currentState == PanelState.closed){
            pc.collapse();
          }
        }
        return SlidingPanel(
          backdropConfig: BackdropConfig(
            enabled: true,
            closeOnTap: false,
            effectInCollapsedMode: false
          ),
//          isDraggable: _bloc.isDraggable,
          autoSizing: PanelAutoSizing(
            autoSizeCollapsed: true
          ),
          duration: Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          isTwoStatePanel: false,
          panelController: pc,
          backPressBehavior: BackPressBehavior.COLLAPSE_CLOSE_POP,
          content: PanelContent(
            panelContent: (BuildContext context, ScrollController controller){
              return InfoWindow(GameProvider.of(context), scrollController: controller,);
            },
            headerWidget: PanelHeaderWidget(
              headerContent: Container(
                height: MediaQuery.of(context).size.height * 0.12,
                child: ShowAction(bloc: GameProvider.of(context),),
              ),
            ),
          ),
          snapPanel: true,
          initialState: InitialPanelState.collapsed,
          size: PanelSize(closedHeight: 0.0, collapsedHeight: 0.12, expandedHeight: 0.85),
        );
      }
    );
  }
}

class InfoWindow extends StatelessWidget {
  InfoWindow(this._bloc, {Key key, this.scrollController}) : super(key: key);

  final GameBloc _bloc;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if(_bloc.selectedTiles.isEmpty){
      return SizedBox.shrink();
    }

    final List<Widget> _options = <Widget>[];
    final List<FactoryEquipmentModel> _selectedEquipment = _bloc.equipment.where((FactoryEquipmentModel fe) => _bloc.selectedTiles.contains(fe.coordinates)).toList();
    final bool _isSameEquipment = _selectedEquipment.every((FactoryEquipmentModel fe) => fe.type == _selectedEquipment.first.type) && _selectedEquipment.length == _bloc.selectedTiles.length;

    if(_bloc.selectedTiles.length > 1 && _selectedEquipment.isNotEmpty && !_isSameEquipment){
      return Container();
    }

    final FactoryEquipmentModel _equipment = _bloc.equipment.firstWhere((FactoryEquipmentModel fe) => _bloc.selectedTiles.first.x == fe.coordinates.x && _bloc.selectedTiles.first.y == fe.coordinates.y, orElse: () => null);

    Widget _buildNoEquipment(){
      return BuildEquipmentWidget(_bloc);
    }

    Widget _showSellerOptions(){
      return SellerInfo(equipment: _equipment);
    }

    Widget _showSelectedInfo(){
      return SelectedObjectInfoWidget(equipment: _equipment, progress: _bloc.progress);
    }

    Widget _showDispenserOptions(){
      return DispenserOptionsWidget(dispenser: _selectedEquipment.where((FactoryEquipmentModel fe) => fe is Dispenser).map<Dispenser>((FactoryEquipmentModel fe) => fe).toList(), progress: _bloc.progress);
    }

    Widget _showSplitterOptions(){
      return SplitterOptionsWidget(splitter: _equipment);
    }

    Widget _showSorterOptions(){
      return SorterOptionsWidget(sorter: _equipment);
    }

    Widget _showCrafterOptions(){
      return CrafterOptionsWidget(crafter: _selectedEquipment.where((FactoryEquipmentModel fe) => fe is Crafter).map<Crafter>((FactoryEquipmentModel fe) => fe).toList(), progress: _bloc.progress);
    }

    Widget _showRotationOptions(){
      return SelectedObjectFooter(_bloc, equipment: _selectedEquipment);
    }

    if(_equipment == null){
      return SingleChildScrollView(
        controller: scrollController,
        child: _buildNoEquipment()
      );
    }

    _options.add(_showSelectedInfo());

    switch(_equipment.type){
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
        _options.add(PortalInfo(equipment: _equipment, connectingPortal: _bloc.equipment.firstWhere((FactoryEquipmentModel fem) => fem.coordinates == (_equipment as UndergroundPortal).connectingPortal, orElse: () => null),));
        break;
    }

    _options.add(_showRotationOptions());

    return Container(
      color: ThemeProvider.of(context).menuColor,
      child: SingleChildScrollView(
        controller: scrollController ?? ScrollController(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: _options,
        ),
      ),
    );
  }
}

class ShowAction extends StatelessWidget {
  ShowAction({Key key, this.bloc}) : super(key: key);

  final GameBloc bloc;

  @override
  Widget build(BuildContext context) {
    if(bloc.selectedTiles.isEmpty){
      return SizedBox.shrink();
    }

    final List<FactoryEquipmentModel> _selectedEquipment = bloc.equipment.where((FactoryEquipmentModel fe) => bloc.selectedTiles.contains(fe.coordinates)).toList();
    final FactoryEquipmentModel _equipment = _selectedEquipment.isEmpty ? null : _selectedEquipment.first;

    if(_equipment == null){
      return BuildEquipmentHeaderWidget();
    }else{
      bool _isNotRotatable = _equipment.type == EquipmentType.portal || _equipment.type == EquipmentType.seller || _equipment.type == EquipmentType.freeRoller || _equipment.type == EquipmentType.rotatingFreeRoller;
      Widget _showRotate = !_isNotRotatable ? Container(
        child: Row(
          children: <Widget>[
            Container(
              height: 200.0,
              width: 60.0,
              child: RaisedButton(
                color: DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: (){
                  GameProvider.of(context).buildSelectedEquipmentDirection = Direction.values[(GameProvider.of(context).buildSelectedEquipmentDirection.index + 1) % Direction.values.length];
                },
                child: Icon(Icons.rotate_right, color: DynamicTheme.of(context).data.neutralActionIconColor,),
              ),
            ),
            Container(
              height: 200.0,
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
                      equipment: GameProvider.of(context).previewEquipment(_selectedEquipment.first.type),
                      objectSize: 48.0,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 60.0,
              height: 200.0,
              child: RaisedButton(
                color: DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: (){
                  GameProvider.of(context).buildSelectedEquipmentDirection = Direction.values[(GameProvider.of(context).buildSelectedEquipmentDirection.index - 1) % Direction.values.length];
                },
                child: Icon(Icons.rotate_left, color: DynamicTheme.of(context).data.neutralActionIconColor,),
              ),
            ),
            Container(
              height: 200.0,
              child: RaisedButton(
                color: DynamicTheme.of(context).data.neutralActionButtonColor,
                onPressed: (){
                  bloc.copyMode = bloc.copyMode == CopyMode.move ? CopyMode.copy : CopyMode.move;
                },
                child: Icon((bloc.copyMode == CopyMode.move) ? Icons.content_cut : Icons.content_copy, color: DynamicTheme.of(context).data.neutralActionIconColor,),
              ),
            ),
          ],
        ),
      ) : SizedBox.shrink();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _showRotate,
          Expanded(
            child: Container(
              height: 200.0,
              child: RaisedButton(
                color: DynamicTheme.of(context).data.negativeActionButtonColor,
                onPressed: (){
                  bloc.equipment.where((FactoryEquipmentModel fe) => bloc.selectedTiles.contains(fe.coordinates)).toList().forEach(bloc.removeEquipment);

                  if(bloc.selectedTiles.length > 1){
                    bloc.selectedTiles.clear();
                  }
                },
                child: Icon(Icons.clear, color:  DynamicTheme.of(context).data.negativeActionIconColor,),
              ),
            ),
          ),
        ],
      );
    }
  }
}
