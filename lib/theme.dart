// TMOD Installer (c) by tricked
//
// TMOD Installer is licensed under a
// Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
//
// You should have received a copy of the license along with this
// work.  If not, see <http://creativecommons.org/licenses/by-nc-nd/3.0/>.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;

enum NavigationIndicators { sticky, end }

class AppTheme extends ChangeNotifier {
  AccentColor _color = systemAccentColor;
  set rawColor(AccentColor color) {
    _color = color;
  }

  AccentColor get color => _color;
  set color(AccentColor color) {
    _color = color;
    notifyListeners();
  }

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  set mode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  set rawMode(ThemeMode mode) {
    _mode = mode;
  }

  PaneDisplayMode _displayMode = PaneDisplayMode.auto;
  PaneDisplayMode get displayMode => _displayMode;
  set displayMode(PaneDisplayMode displayMode) {
    _displayMode = displayMode;
    notifyListeners();
  }

  set rawDisplayMode(PaneDisplayMode displayMode) {
    _displayMode = displayMode;
  }

  NavigationIndicators _indicator = NavigationIndicators.sticky;
  NavigationIndicators get indicator => _indicator;
  set indicator(NavigationIndicators indicator) {
    _indicator = indicator;
    notifyListeners();
  }

  flutter_acrylic.WindowEffect _acrylicEffect =
      flutter_acrylic.WindowEffect.disabled;
  flutter_acrylic.WindowEffect get acrylicEffect => _acrylicEffect;
  set acrylicEffect(flutter_acrylic.WindowEffect acrylicEffect) {
    _acrylicEffect = acrylicEffect;
    notifyListeners();
  }

  TextDirection _textDirection = TextDirection.ltr;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection direction) {
    _textDirection = direction;
    notifyListeners();
  }
}

AccentColor get systemAccentColor {
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.android ||
      kIsWeb) {
    return AccentColor('normal', {
      'darkest': SystemTheme.accentInstance.darkest,
      'darker': SystemTheme.accentInstance.darker,
      'dark': SystemTheme.accentInstance.dark,
      'normal': SystemTheme.accentInstance.accent,
      'light': SystemTheme.accentInstance.light,
      'lighter': SystemTheme.accentInstance.lighter,
      'lightest': SystemTheme.accentInstance.lightest,
    });
  }
  return Colors.blue;
}
