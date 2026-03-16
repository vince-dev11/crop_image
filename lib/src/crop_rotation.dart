import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rotation class supporting ANY angle
class CropRotation {
  final double degrees;

  const CropRotation(this.degrees);

  /// Convert degrees to radians
  double get radians => degrees * math.pi / 180;

  /// Rotate right by given amount (default 90)
  CropRotation rotateRight([double amount = 90]) {
    return CropRotation(degrees + amount);
  }

  /// Rotate left by given amount (default 90)
  CropRotation rotateLeft([double amount = 90]) {
    return CropRotation(degrees - amount);
  }

  /// Returns true if image is sideways
  bool get isSideways {
    final normalized = degrees % 180;
    return normalized != 0;
  }

  /// Rotate a point around image center
  Offset getRotatedOffset(
    Offset offset01,
    double width,
    double height,
  ) {
    final center = Offset(width / 2, height / 2);

    final point = Offset(
      offset01.dx * width,
      offset01.dy * height,
    );

    final translated = point - center;

    final cosA = math.cos(radians);
    final sinA = math.sin(radians);

    final rotated = Offset(
      translated.dx * cosA - translated.dy * sinA,
      translated.dx * sinA + translated.dy * cosA,
    );

    return rotated + center;
  }

  /// Normalize degrees between 0-360
  double get normalizedDegrees {
    double deg = degrees % 360;
    if (deg < 0) deg += 360;
    return deg;
  }

  /// Create rotation from degrees
  factory CropRotation.fromDegrees(double deg) {
    return CropRotation(deg);
  }

  @override
  String toString() {
    return "CropRotation($degrees°)";
  }
}