import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // Spacing Constants
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Screen Padding
  static const double screenPadding = 20.0;
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: screenPadding);

  // Dimensions
  static const double cardRadius = 16.0;
  static const double buttonHeight = 48.0;

  // Predefined BorderRadius
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(cardRadius));
}
