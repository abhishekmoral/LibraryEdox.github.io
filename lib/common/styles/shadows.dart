import 'package:flutter/material.dart';

/// Reusable [BoxShadow] presets used across the EdoxLibrary application.
class XShadowStyle {
  XShadowStyle._();

  /// A subtle vertical shadow – good for bottom-anchored elements.
  static final BoxShadow verticalShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 12,
    spreadRadius: 2,
    offset: const Offset(0, 4),
  );

  /// A subtle horizontal shadow – useful for side panels.
  static final BoxShadow horizontalShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 12,
    spreadRadius: 2,
    offset: const Offset(4, 0),
  );

  /// A very subtle shadow for dashboard stat / info cards.
  static final BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 8,
    spreadRadius: 1,
    offset: const Offset(0, 2),
  );

  /// A slightly stronger shadow for seat-card elements.
  static final BoxShadow seatCardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.10),
    blurRadius: 10,
    spreadRadius: 1,
    offset: const Offset(0, 3),
  );
}
