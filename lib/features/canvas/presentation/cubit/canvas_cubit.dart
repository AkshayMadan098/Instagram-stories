import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'canvas_state.dart';
import '../../domain/entities/drawing_stroke.dart';
import '../../domain/entities/sticker_item.dart';
import '../../domain/entities/caption_model.dart';
import '../../../stickers/domain/entities/sticker_definition.dart';
import '../../../../core/utils/image_saver.dart';

class CanvasCubit extends Cubit<CanvasState> {
  final Uuid _uuid = const Uuid();

  CanvasCubit({required String imagePath})
      : super(CanvasState(imagePath: imagePath));

  void setTool(CanvasTool tool) {
    if (state.activeTool == tool) {
      emit(state.copyWith(activeTool: CanvasTool.none));
    } else {
      emit(state.copyWith(activeTool: tool));
    }
  }

  void setColor(Color color) {
    emit(state.copyWith(activeColor: color));
  }

  void setStrokeWidth(double width) {
    emit(state.copyWith(strokeWidth: width));
  }

  void startStroke(Offset point) {
    final newStroke = DrawingStroke(
      points: [point],
      color: state.activeTool == CanvasTool.eraser
          ? Colors.transparent
          : state.activeColor,
      strokeWidth: state.strokeWidth,
      isEraser: state.activeTool == CanvasTool.eraser,
    );
    emit(state.copyWith(currentStroke: newStroke));
  }

  void updateStroke(Offset point) {
    if (state.currentStroke == null) return;
    final updatedPoints = List<Offset>.from(state.currentStroke!.points)
      ..add(point);
    emit(state.copyWith(
      currentStroke: state.currentStroke!.copyWith(points: updatedPoints),
    ));
  }

  void endStroke() {
    if (state.currentStroke == null) return;
    final updatedStrokes = List<DrawingStroke>.from(state.strokes)
      ..add(state.currentStroke!);
    emit(state.copyWith(
      strokes: updatedStrokes,
      clearCurrentStroke: true,
      undoStack: [],
    ));
  }

  void undo() {
    if (state.strokes.isEmpty) return;
    final updatedStrokes = List<DrawingStroke>.from(state.strokes);
    final lastStroke = updatedStrokes.removeLast();
    final updatedUndoStack = List<DrawingStroke>.from(state.undoStack)
      ..add(lastStroke);
    emit(state.copyWith(
      strokes: updatedStrokes,
      undoStack: updatedUndoStack,
    ));
  }

  void clearStrokes() {
    emit(state.copyWith(
      strokes: [],
      undoStack: [],
      clearCurrentStroke: true,
    ));
  }

  // --- Sticker Operations ---

  void addSticker(StickerDefinition definition, Size canvasSize) {
    final stickerId = _uuid.v4();
    // Default position at center of screen
    final position = Offset(
      canvasSize.width / 2,
      canvasSize.height / 2,
    );

    final newSticker = StickerItem(
      id: stickerId,
      definition: definition,
      position: position,
      scale: 1.0,
      rotation: 0.0,
    );

    final updatedStickers = List<StickerItem>.from(state.stickers)
      ..add(newSticker);
    emit(state.copyWith(
      stickers: updatedStickers,
      selectedStickerId: stickerId,
      activeTool: CanvasTool.none,
    ));
  }

  void updateStickerTransform(
    String id, {
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    final updatedStickers = state.stickers.map((item) {
      if (item.id == id) {
        return item.copyWith(
          position: position ?? item.position,
          scale: scale ?? item.scale,
          rotation: rotation ?? item.rotation,
        );
      }
      return item;
    }).toList();

    emit(state.copyWith(stickers: updatedStickers));
  }

  void deleteSticker(String id) {
    final updatedStickers =
        state.stickers.where((item) => item.id != id).toList();
    emit(state.copyWith(
      stickers: updatedStickers,
      clearSelectedStickerId: state.selectedStickerId == id,
    ));
  }

  void selectSticker(String? id) {
    emit(state.copyWith(
      selectedStickerId: id,
      clearSelectedStickerId: id == null,
    ));
  }

  // --- Caption Operations ---

  void setCaption(CaptionModel caption) {
    emit(state.copyWith(
      caption: caption,
      activeTool: CanvasTool.none,
    ));
  }

  void updateCaptionTransform({
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    if (state.caption == null) return;
    emit(state.copyWith(
      caption: state.caption!.copyWith(
        position: position ?? state.caption!.position,
        scale: scale ?? state.caption!.scale,
        rotation: rotation ?? state.caption!.rotation,
      ),
    ));
  }

  void removeCaption() {
    emit(state.copyWith(clearCaption: true));
  }

  // --- Export Canvas ---

  Future<String?> exportCanvas(GlobalKey repaintKey) async {
    try {
      emit(state.copyWith(isExporting: true, errorMessage: null));
      // Deselect any active sticker so selection outlines are not baked into final image
      emit(state.copyWith(clearSelectedStickerId: true, activeTool: CanvasTool.none));

      // Allow UI frame to settle without selection outlines
      await Future.delayed(const Duration(milliseconds: 100));

      final imagePath = await ImageSaver.captureWidgetToImage(repaintKey);

      emit(state.copyWith(
        isExporting: false,
        exportedImagePath: imagePath,
      ));
      return imagePath;
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        errorMessage: 'Failed to export image: $e',
      ));
      return null;
    }
  }
}
