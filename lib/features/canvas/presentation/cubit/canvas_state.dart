import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/drawing_stroke.dart';
import '../../domain/entities/sticker_item.dart';
import '../../domain/entities/caption_model.dart';
import '../../../../core/constants/app_constants.dart';

enum CanvasTool {
  none,
  brush,
  eraser,
  text,
  sticker,
}

class CanvasState extends Equatable {
  final String imagePath;
  final CanvasTool activeTool;
  final List<DrawingStroke> strokes;
  final List<DrawingStroke> undoStack;
  final DrawingStroke? currentStroke;
  final Color activeColor;
  final double strokeWidth;
  final List<StickerItem> stickers;
  final String? selectedStickerId;
  final CaptionModel? caption;
  final bool isExporting;
  final String? exportedImagePath;
  final String? errorMessage;

  const CanvasState({
    required this.imagePath,
    this.activeTool = CanvasTool.none,
    this.strokes = const [],
    this.undoStack = const [],
    this.currentStroke,
    this.activeColor = Colors.white,
    this.strokeWidth = AppConstants.defaultStrokeWidth,
    this.stickers = const [],
    this.selectedStickerId,
    this.caption,
    this.isExporting = false,
    this.exportedImagePath,
    this.errorMessage,
  });

  bool get canUndo => strokes.isNotEmpty;
  bool get hasEdits => strokes.isNotEmpty || stickers.isNotEmpty || caption != null;

  CanvasState copyWith({
    String? imagePath,
    CanvasTool? activeTool,
    List<DrawingStroke>? strokes,
    List<DrawingStroke>? undoStack,
    DrawingStroke? currentStroke,
    bool clearCurrentStroke = false,
    Color? activeColor,
    double? strokeWidth,
    List<StickerItem>? stickers,
    String? selectedStickerId,
    bool clearSelectedStickerId = false,
    CaptionModel? caption,
    bool clearCaption = false,
    bool? isExporting,
    String? exportedImagePath,
    String? errorMessage,
  }) {
    return CanvasState(
      imagePath: imagePath ?? this.imagePath,
      activeTool: activeTool ?? this.activeTool,
      strokes: strokes ?? this.strokes,
      undoStack: undoStack ?? this.undoStack,
      currentStroke:
          clearCurrentStroke ? null : (currentStroke ?? this.currentStroke),
      activeColor: activeColor ?? this.activeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      stickers: stickers ?? this.stickers,
      selectedStickerId: clearSelectedStickerId
          ? null
          : (selectedStickerId ?? this.selectedStickerId),
      caption: clearCaption ? null : (caption ?? this.caption),
      isExporting: isExporting ?? this.isExporting,
      exportedImagePath: exportedImagePath ?? this.exportedImagePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        imagePath,
        activeTool,
        strokes,
        undoStack,
        currentStroke,
        activeColor,
        strokeWidth,
        stickers,
        selectedStickerId,
        caption,
        isExporting,
        exportedImagePath,
        errorMessage,
      ];
}
