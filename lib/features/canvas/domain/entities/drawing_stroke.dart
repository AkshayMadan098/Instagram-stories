import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DrawingStroke extends Equatable {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  const DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });

  DrawingStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    bool? isEraser,
  }) {
    return DrawingStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isEraser: isEraser ?? this.isEraser,
    );
  }

  @override
  List<Object?> get props => [points, color, strokeWidth, isEraser];
}
