// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_factory/ui/theme/light_game_theme.dart';

import 'game_theme.dart';

/// The duration over which theme changes animate by default.
const Duration kThemeProviderAnimationDuration = Duration(milliseconds: 200);

/// Applies a theme to descendant widgets.
///
/// A theme describes the colors and typographic choices of an application.
///
/// Descendant widgets obtain the current theme's [GameTheme] object using
/// [ThemeProvider.of]. When a widget uses [ThemeProvider.of], it is automatically rebuilt if
/// the theme later changes, so that the changes can be applied.
///
/// The [ThemeProvider] widget implies an [IconThemeProvider] widget, set to the value of the
/// [GameTheme.iconThemeProvider] of the [data] for the [ThemeProvider].
///
/// See also:
///
///  * [GameTheme], which describes the actual configuration of a theme.
///  * [AnimatedThemeProvider], which animates the [GameTheme] when it changes rather
///    than changing the theme all at once.
///  * [MaterialApp], which includes an [AnimatedThemeProvider] widget configured via
///    the [MaterialApp.theme] argument.
class ThemeProvider extends StatelessWidget {
  /// Applies the given theme [data] to [child].
  ///
  /// The [data] and [child] arguments must not be null.
  const ThemeProvider({
    Key key,
    @required this.data,
    this.isMaterialAppThemeProvider = false,
    @required this.child,
  }) : assert(child != null),
      assert(data != null),
      super(key: key);

  /// Specifies the color and typography values for descendant widgets.
  final GameTheme data;

  /// True if this theme was installed by the [MaterialApp].
  ///
  /// When an app uses the [Navigator] to push a route, the route's widgets
  /// will only inherit from the app's theme, even though the widget that
  /// triggered the push may inherit from a theme that "shadows" the app's
  /// theme because it's deeper in the widget tree. Apps can find the shadowing
  /// theme with `ThemeProvider.of(context, shadowThemeProviderOnly: true)` and pass it along
  /// to the class that creates a route's widgets. Material widgets that push
  /// routes, like [PopupMenuButton] and [DropdownButton], do this.
  final bool isMaterialAppThemeProvider;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  static final GameTheme _kFallbackThemeProvider = LightGameTheme();

  /// The data from the closest [ThemeProvider] instance that encloses the given
  /// context.
  ///
  /// If the given context is enclosed in a [Localizations] widget providing
  /// [MaterialLocalizations], the returned data is localized according to the
  /// nearest available [MaterialLocalizations].
  ///
  /// Defaults to [new GameTheme.fallback] if there is no [ThemeProvider] in the given
  /// build context.
  ///
  /// If [shadowThemeProviderOnly] is true and the closest [ThemeProvider] ancestor was
  /// installed by the [MaterialApp] — in other words if the closest [ThemeProvider]
  /// ancestor does not shadow the application's theme — then this returns null.
  /// This argument should be used in situations where its useful to wrap a
  /// route's widgets with a [ThemeProvider], but only when the application's overall
  /// theme is being shadowed by a [ThemeProvider] widget that is deeper in the tree.
  /// See [isMaterialAppThemeProvider].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Text(
  ///     'Example',
  ///     style: ThemeProvider.of(context).textThemeProvider.title,
  ///   );
  /// }
  /// ```
  ///
  /// When the [ThemeProvider] is actually created in the same `build` function
  /// (possibly indirectly, e.g. as part of a [MaterialApp]), the `context`
  /// argument to the `build` function can't be used to find the [ThemeProvider] (since
  /// it's "above" the widget being returned). In such cases, the following
  /// technique with a [Builder] can be used to provide a new scope with a
  /// [BuildContext] that is "under" the [ThemeProvider]:
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return MaterialApp(
  ///     theme: GameTheme.light(),
  ///     body: Builder(
  ///       // Create an inner BuildContext so that we can refer to
  ///       // the ThemeProvider with ThemeProvider.of().
  ///       builder: (BuildContext context) {
  ///         return Center(
  ///           child: Text(
  ///             'Example',
  ///             style: ThemeProvider.of(context).textThemeProvider.title,
  ///           ),
  ///         );
  ///       },
  ///     ),
  ///   );
  /// }
  /// ```
  static GameTheme of(BuildContext context, { bool shadowThemeProviderOnly = false }) {
    final _InheritedGameThemeProvider inheritedThemeProvider = context.inheritFromWidgetOfExactType(_InheritedGameThemeProvider);
    if (shadowThemeProviderOnly) {
      if (inheritedThemeProvider == null || inheritedThemeProvider.theme.isMaterialAppThemeProvider)
        return null;
      return inheritedThemeProvider.theme.data;
    }

    final GameTheme theme = inheritedThemeProvider?.theme?.data ?? _kFallbackThemeProvider;
    return theme;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedGameThemeProvider(
      theme: this,
      child: child
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<GameTheme>('data', data, showName: false));
  }
}

class _InheritedGameThemeProvider extends InheritedTheme {
  const _InheritedGameThemeProvider({
    Key key,
    @required this.theme,
    @required Widget child,
  }) : assert(theme != null),
      super(key: key, child: child);

  final ThemeProvider theme;

  @override
  Widget wrap(BuildContext context, Widget child) {
    final _InheritedGameThemeProvider ancestorThemeProvider = context.ancestorWidgetOfExactType(_InheritedGameThemeProvider);
    return identical(this, ancestorThemeProvider) ? child : ThemeProvider(data: theme.data, child: child);
  }

  @override
  bool updateShouldNotify(_InheritedGameThemeProvider old) => theme.data != old.theme.data;
}

/// An interpolation between two [GameTheme]s.
///
/// This class specializes the interpolation of [Tween<GameTheme>] to call the
/// [GameTheme.lerp] method.
///
/// See [Tween] for a discussion on how to use interpolation objects.
class GameThemeTween extends Tween<GameTheme> {
  /// Creates a [GameTheme] tween.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  GameThemeTween({ GameTheme begin, GameTheme end }) : super(begin: begin, end: end);

  @override
  GameTheme lerp(double t) => GameTheme.lerp(begin, end, t);
}

/// Animated version of [ThemeProvider] which automatically transitions the colors,
/// etc, over a given duration whenever the given theme changes.
///
/// Here's an illustration of what using this widget looks like, using a [curve]
/// of [Curves.elasticInOut].
/// {@animation 250 266 https://flutter.github.io/assets-for-api-docs/assets/widgets/animated_theme.mp4}
///
/// See also:
///
///  * [ThemeProvider], which [AnimatedThemeProvider] uses to actually apply the interpolated
///    theme.
///  * [GameTheme], which describes the actual configuration of a theme.
///  * [MaterialApp], which includes an [AnimatedThemeProvider] widget configured via
///    the [MaterialApp.theme] argument.
class AnimatedThemeProvider extends ImplicitlyAnimatedWidget {
  /// Creates an animated theme.
  ///
  /// By default, the theme transition uses a linear curve. The [data] and
  /// [child] arguments must not be null.
  const AnimatedThemeProvider({
    Key key,
    @required this.data,
    this.isMaterialAppThemeProvider = false,
    Curve curve = Curves.linear,
    Duration duration = kThemeProviderAnimationDuration,
    @required this.child,
  }) : assert(child != null),
      assert(data != null),
      super(key: key, curve: curve, duration: duration);

  /// Specifies the color and typography values for descendant widgets.
  final GameTheme data;

  /// True if this theme was created by the [MaterialApp]. See [ThemeProvider.isMaterialAppThemeProvider].
  final bool isMaterialAppThemeProvider;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  _AnimatedThemeProviderState createState() => _AnimatedThemeProviderState();
}

class _AnimatedThemeProviderState extends AnimatedWidgetBaseState<AnimatedThemeProvider> {
  GameThemeTween _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    // TODO(ianh): Use constructor tear-offs when it becomes possible
    _data = visitor(_data, widget.data, (dynamic value) => GameThemeTween(begin: value));
    assert(_data != null);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      isMaterialAppThemeProvider: widget.isMaterialAppThemeProvider,
      child: widget.child,
      data: _data.evaluate(animation),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<GameThemeTween>('data', _data, showName: false, defaultValue: null));
  }
}
