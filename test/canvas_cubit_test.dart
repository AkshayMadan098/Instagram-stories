import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_stories/features/canvas/domain/entities/caption_model.dart';
import 'package:instagram_stories/features/canvas/presentation/cubit/canvas_cubit.dart';
import 'package:instagram_stories/features/canvas/presentation/cubit/canvas_state.dart';
import 'package:instagram_stories/features/stickers/data/datasources/project_status_stickers_catalog.dart';

void main() {
  group('CanvasCubit', () {
    late CanvasCubit cubit;

    setUp(() {
      cubit = CanvasCubit(imagePath: '/test/sample.png');
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has correct imagePath and defaults', () {
      expect(cubit.state.imagePath, '/test/sample.png');
      expect(cubit.state.activeTool, CanvasTool.none);
      expect(cubit.state.strokes, isEmpty);
      expect(cubit.state.stickers, isEmpty);
      expect(cubit.state.caption, isNull);
      expect(cubit.state.canUndo, isFalse);
    });

    test('drawing strokes: start, update, end, and undo', () {
      cubit.setTool(CanvasTool.brush);
      expect(cubit.state.activeTool, CanvasTool.brush);

      cubit.startStroke(const Offset(10, 10));
      expect(cubit.state.currentStroke, isNotNull);
      expect(cubit.state.currentStroke!.points, [const Offset(10, 10)]);

      cubit.updateStroke(const Offset(20, 20));
      expect(cubit.state.currentStroke!.points.length, 2);

      cubit.endStroke();
      expect(cubit.state.currentStroke, isNull);
      expect(cubit.state.strokes.length, 1);
      expect(cubit.state.canUndo, isTrue);

      // Undo stroke
      cubit.undo();
      expect(cubit.state.strokes, isEmpty);
      expect(cubit.state.undoStack.length, 1);
    });

    test('stickers: add, select, update transform, and delete', () {
      final stickerDef = ProjectStatusStickersCatalog.allStickers.first;
      cubit.addSticker(stickerDef, const Size(400, 800));

      expect(cubit.state.stickers.length, 1);
      final addedSticker = cubit.state.stickers.first;
      expect(addedSticker.definition.id, stickerDef.id);
      expect(cubit.state.selectedStickerId, addedSticker.id);

      // Update transform
      cubit.updateStickerTransform(
        addedSticker.id,
        position: const Offset(150, 300),
        scale: 1.5,
        rotation: 0.25,
      );

      final updatedSticker = cubit.state.stickers.first;
      expect(updatedSticker.position, const Offset(150, 300));
      expect(updatedSticker.scale, 1.5);
      expect(updatedSticker.rotation, 0.25);

      // Delete sticker
      cubit.deleteSticker(addedSticker.id);
      expect(cubit.state.stickers, isEmpty);
      expect(cubit.state.selectedStickerId, isNull);
    });

    test('caption: set, transform, and remove', () {
      const caption = CaptionModel(
        id: 'cap_1',
        text: 'Project Launch Ready!',
        position: Offset(200, 400),
      );

      cubit.setCaption(caption);
      expect(cubit.state.caption, isNotNull);
      expect(cubit.state.caption!.text, 'Project Launch Ready!');

      cubit.updateCaptionTransform(position: const Offset(210, 420), scale: 1.2);
      expect(cubit.state.caption!.position, const Offset(210, 420));
      expect(cubit.state.caption!.scale, 1.2);

      cubit.removeCaption();
      expect(cubit.state.caption, isNull);
    });
  });
}
