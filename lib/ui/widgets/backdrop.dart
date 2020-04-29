// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double _kFrontHeadingHeight = 32.0; // front layer beveled rectangle
const double _kFrontClosedHeight = 80.0; //92.0; // front layer height when closed

// The size of the front layer heading's left and right beveled corners.
final Animatable<BorderRadius> _kFrontHeadingBevelRadius = BorderRadiusTween(
  begin: const BorderRadius.only(
    topLeft: Radius.circular(12.0),
    topRight: Radius.circular(12.0),
  ),
  end: const BorderRadius.only(
    topLeft: Radius.circular(_kFrontHeadingHeight),
    topRight: Radius.circular(_kFrontHeadingHeight),
  ),
);

class _TappableWhileStatusIs extends StatefulWidget {
  const _TappableWhileStatusIs(
    this.status, {
    Key key,
    this.controller,
    this.child,
  }) : super(key: key);

  final AnimationController controller;
  final AnimationStatus status;
  final Widget child;

  @override
  _TappableWhileStatusIsState createState() => _TappableWhileStatusIsState();
}

class _TappableWhileStatusIsState extends State<_TappableWhileStatusIs> {
  bool _active;

  @override
  void initState() {
    super.initState();
    widget.controller.addStatusListener(_handleStatusChange);
    _active = widget.controller.status == widget.status;
  }

  @override
  void dispose() {
    widget.controller.removeStatusListener(_handleStatusChange);
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    final bool value = widget.controller.status == widget.status;
    if (_active != value) {
      setState(() {
        _active = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !_active,
      child: widget.child,
    );
  }
}

class Backdrop extends StatefulWidget {
  const Backdrop(
      {this.frontTitle, this.frontLayer, this.backTitle, this.backLayer, this.controller, this.firstLayerHeight = 400});

  final AnimationController controller;
  final Widget frontTitle;
  final Widget frontLayer;
  final Widget backTitle;
  final Widget backLayer;
  final double firstLayerHeight;

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop> with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _controller;
  Animation<double> _frontBlur;

  static final Animatable<double> _frontBlurTween =
      Tween<double>(begin: 0.0, end: 0.8).chain(CurveTween(curve: const Interval(0.2, 0.8, curve: Curves.easeInOut)));

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        );

    _frontBlur = _controller.drive(_frontBlurTween);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final Animation<RelativeRect> frontRelativeRect = _controller.drive(RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, constraints.biggest.height - _kFrontClosedHeight, 0.0, 0.0),
      end: RelativeRect.fromLTRB(
          0.0, constraints.biggest.height - _kFrontClosedHeight - constraints.biggest.height / 2 + 80.0, 0.0, 0.0),
    ));

    final List<Widget> layers = <Widget>[
      // Back layer
      Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: widget.backLayer,
              ),
            ],
          ),
          IgnorePointer(
            ignoring: true,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _frontBlur.value, sigmaY: _frontBlur.value),
              child: Container(
                color: Colors.black.withOpacity(min(_frontBlur.value, 0.2)),
              ),
            ),
          ),
        ],
      ),
      // Front layer
      PositionedTransition(
        rect: frontRelativeRect,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget child) {
            return PhysicalShape(
              elevation: 12.0,
              color: Theme.of(context).canvasColor,
              clipper: ShapeBorderClipper(
                shape: BeveledRectangleBorder(
                  borderRadius: _kFrontHeadingBevelRadius.transform(_controller.value),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            );
          },
          child: widget.frontLayer,
        ),
      ),
    ];

    return Stack(
      key: _backdropKey,
      children: layers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildStack);
  }
}
