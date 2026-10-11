import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CaptionFontStyle {
  modern,
  classic,
  neon,
  typewriter,
  strong,
}

class CaptionModel extends Equatable {
  final String id;
  final String text;
  final Color textColor;
  final bool hasBackground;
  final Color backgroundColor;
  final Offset position;
  final double scale;
  final double rotation;
  final CaptionFontStyle fontStyle;

  const CaptionModel({
    required this.id,
    required this.text,
    this.textColor = Colors.white,
    this.hasBackground = true,
    this.backgroundColor = Colors.black87,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.fontStyle = CaptionFontStyle.modern,
  });

  CaptionModel copyWith({
    String? id,
    String? text,
    Color? textColor,
    bool? hasBackground,
    Color? backgroundColor,
    Offset? position,
    double? scale,
    double? rotation,
    CaptionFontStyle? fontStyle,
  }) {
    return CaptionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      textColor: textColor ?? this.textColor,
      hasBackground: hasBackground ?? this.hasBackground,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      fontStyle: fontStyle ?? this.fontStyle,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        textColor,
        hasBackground,
        backgroundColor,
        position,
        scale,
        rotation,
        fontStyle,
      ];
}
