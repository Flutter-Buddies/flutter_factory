import 'package:flutter/material.dart';
import 'package:flutter_factory/game/equipment/seller.dart';

class SellerInfo extends StatelessWidget {
  SellerInfo({Key key, @required this.equipment}) : super(key: key);

  final Seller equipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Text(equipment.soldValue.toStringAsFixed(2)),
            Text(equipment.soldAverage.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }
}
