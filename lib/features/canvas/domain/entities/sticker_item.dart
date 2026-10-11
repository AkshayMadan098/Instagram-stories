import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../stickers/domain/entities/sticker_definition.dart';

class StickerItem extends Equatable {
  final String id;
  final StickerDefinition definition;
  final Offset position;
  final double scale;
  final double rotation;

  const StickerItem({
    required this.id,
    required this.definition,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  StickerItem copyWith({
    String? id,
    StickerDefinition? definition,
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    return StickerItem(
      id: id ?? this.id,
      definition: definition ?? this.definition,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  List<Object?> get props => [id, definition, position, scale, rotation];
}
