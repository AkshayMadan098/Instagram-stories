import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum StickerBadgeShape {
  speechBubble,
  starburst,
  pill,
  flame,
  stamp,
  warningTape,
  shield,
  roundedRect,
}

class StickerDefinition extends Equatable {
  final String id;
  final String text;
  final String category;
  final StickerBadgeShape shape;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color strokeColor;
  final IconData? icon;
  final String? emoji;

  const StickerDefinition({
    required this.id,
    required this.text,
    required this.category,
    required this.shape,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    this.strokeColor = Colors.white,
    this.icon,
    this.emoji,
  });

  @override
  List<Object?> get props => [
        id,
        text,
        category,
        shape,
        primaryColor,
        secondaryColor,
        textColor,
        strokeColor,
        icon,
        emoji,
      ];
}
