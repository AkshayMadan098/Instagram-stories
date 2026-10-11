import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/canvas_cubit.dart';
import '../cubit/canvas_state.dart';
import '../widgets/drawing_painter.dart';
import '../widgets/interactive_sticker_widget.dart';
import '../widgets/interactive_caption_widget.dart';
import '../widgets/color_palette_bar.dart';
import '../widgets/caption_input_dialog.dart';
import '../widgets/discard_dialog.dart';
import '../../../stickers/presentation/widgets/sticker_picker_sheet.dart';
import '../../../instagram_share/presentation/cubit/instagram_share_cubit.dart';
import '../../../instagram_share/presentation/widgets/instagram_share_modal.dart';

class PhotoCanvasPage extends StatefulWidget {
  final String imagePath;

  const PhotoCanvasPage({
    super.key,
    required this.imagePath,
  });

  static Route<void> route({required String imagePath}) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => CanvasCubit(imagePath: imagePath),
        child: PhotoCanvasPage(imagePath: imagePath),
      ),
    );
  }

  @override
  State<PhotoCanvasPage> createState() => _PhotoCanvasPageState();
}

class _PhotoCanvasPageState extends State<PhotoCanvasPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Future<void> _handleDiscard() async {
    final cubit = context.read<CanvasCubit>();
    if (cubit.state.hasEdits) {
      final shouldDiscard = await DiscardDialog.show(context);
      if (shouldDiscard == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleShareToInstagramStory() async {
    final canvasCubit = context.read<CanvasCubit>();
    final shareCubit = context.read<InstagramShareCubit>();

    // 1. Export canvas image
    final exportedPath = await canvasCubit.exportCanvas(_repaintBoundaryKey);
    if (!mounted) return;
    if (exportedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export canvas image')),
      );
      return;
    }

    final captionText = canvasCubit.state.caption?.text;

    // 2. Open Instagram Share Modal
    InstagramShareModal.show(
      context,
      imagePath: exportedPath,
      caption: captionText,
    );

    // 3. Trigger direct share to Instagram Story
    shareCubit.shareToInstagramStory(
      imagePath: exportedPath,
      caption: captionText,
    );
  }

  Future<void> _handleSaveExportOnly() async {
    final canvasCubit = context.read<CanvasCubit>();
    final exportedPath = await canvasCubit.exportCanvas(_repaintBoundaryKey);

    if (exportedPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF333333),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Story saved to: ${exportedPath.split('/').last}'),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleDiscard();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<CanvasCubit, CanvasState>(
          builder: (context, state) {
            final isDrawingMode = state.activeTool == CanvasTool.brush ||
                state.activeTool == CanvasTool.eraser;

            return Stack(
              children: [
                // 1. MAIN STORY CANVAS (Inside RepaintBoundary)
                Positioned.fill(
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Photo
                        _buildBackgroundImage(),

                        // Drawing layer
                        CustomPaint(
                          painter: DrawingPainter(
                            strokes: state.strokes,
                            currentStroke: state.currentStroke,
                          ),
                          size: Size.infinite,
                        ),

                        // Stickers layer
                        ...state.stickers.map((stickerItem) {
                          return InteractiveStickerWidget(
                            key: ValueKey(stickerItem.id),
                            stickerItem: stickerItem,
                            isSelected:
                                state.selectedStickerId == stickerItem.id,
                            onTap: () {
                              context
                                  .read<CanvasCubit>()
                                  .selectSticker(stickerItem.id);
                            },
                            onDelete: () {
                              context
                                  .read<CanvasCubit>()
                                  .deleteSticker(stickerItem.id);
                            },
                            onTransformUpdate: (pos, scale, rot) {
                              context
                                  .read<CanvasCubit>()
                                  .updateStickerTransform(
                                    stickerItem.id,
                                    position: pos,
                                    scale: scale,
                                    rotation: rot,
                                  );
                            },
                          );
                        }),

                        // Caption layer
                        if (state.caption != null)
                          InteractiveCaptionWidget(
                            key: ValueKey(state.caption!.id),
                            caption: state.caption!,
                            isSelected: state.activeTool == CanvasTool.text,
                            onTap: () {
                              CaptionInputDialog.show(
                                context,
                                initialCaption: state.caption,
                                onDone: (newCaption) {
                                  context
                                      .read<CanvasCubit>()
                                      .setCaption(newCaption);
                                },
                              );
                            },
                            onDelete: () {
                              context.read<CanvasCubit>().removeCaption();
                            },
                            onTransformUpdate: (pos, scale, rot) {
                              context
                                  .read<CanvasCubit>()
                                  .updateCaptionTransform(
                                    position: pos,
                                    scale: scale,
                                    rotation: rot,
                                  );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // 2. DRAWING GESTURE DETECTOR (When Drawing Mode is active)
                if (isDrawingMode)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanStart: (details) {
                        context
                            .read<CanvasCubit>()
                            .startStroke(details.localPosition);
                      },
                      onPanUpdate: (details) {
                        context
                            .read<CanvasCubit>()
                            .updateStroke(details.localPosition);
                      },
                      onPanEnd: (_) {
                        context.read<CanvasCubit>().endStroke();
                      },
                    ),
                  ),

                // Tap outside stickers/caption to deselect
                if (!isDrawingMode)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        context.read<CanvasCubit>().selectSticker(null);
                      },
                    ),
                  ),

                // 3. TOP ACTION TOOLBAR
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopToolbar(context, state, isDrawingMode),
                ),

                // 4. BOTTOM ACTION BAR / PALETTE
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: isDrawingMode
                      ? ColorPaletteBar(
                          activeColor: state.activeColor,
                          strokeWidth: state.strokeWidth,
                          isEraserActive:
                              state.activeTool == CanvasTool.eraser,
                          onColorChanged: (color) {
                            final cubit = context.read<CanvasCubit>();
                            cubit.setTool(CanvasTool.brush);
                            cubit.setColor(color);
                          },
                          onStrokeWidthChanged: (size) {
                            context.read<CanvasCubit>().setStrokeWidth(size);
                          },
                          onToggleEraser: () {
                            final cubit = context.read<CanvasCubit>();
                            cubit.setTool(
                              cubit.state.activeTool == CanvasTool.eraser
                                  ? CanvasTool.brush
                                  : CanvasTool.eraser,
                            );
                          },
                          onClearAll: () {
                            context.read<CanvasCubit>().clearStrokes();
                          },
                        )
                      : _buildBottomShareBar(context, state),
                ),

                // Exporting overlay loader
                if (state.isExporting)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.instagramPink,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    final file = File(widget.imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    // Fallback placeholder image gradient
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _buildTopToolbar(
      BuildContext context, CanvasState state, bool isDrawingMode) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 12,
        right: 12,
        bottom: 8,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black87, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Discard / Retake (X)
          _buildCircleIconButton(
            icon: Icons.close,
            tooltip: 'Discard',
            onTap: _handleDiscard,
          ),

          const Spacer(),

          if (isDrawingMode) ...[
            // Undo stroke
            if (state.canUndo)
              _buildCircleIconButton(
                icon: Icons.undo,
                tooltip: 'Undo',
                onTap: () => context.read<CanvasCubit>().undo(),
              ),
            const SizedBox(width: 8),

            // Done drawing button
            TextButton(
              onPressed: () {
                context.read<CanvasCubit>().setTool(CanvasTool.none);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            // Undo stroke
            if (state.canUndo)
              _buildCircleIconButton(
                icon: Icons.undo,
                tooltip: 'Undo Drawing',
                onTap: () => context.read<CanvasCubit>().undo(),
              ),
            const SizedBox(width: 8),

            // Text / Caption tool (Aa)
            _buildCircleIconButton(
              icon: Icons.text_fields,
              tooltip: 'Add Caption',
              onTap: () {
                CaptionInputDialog.show(
                  context,
                  initialCaption: state.caption,
                  onDone: (caption) {
                    context.read<CanvasCubit>().setCaption(caption);
                  },
                );
              },
            ),
            const SizedBox(width: 8),

            // Stickers tool (Smile / Figma Project Status Stickers)
            _buildCircleIconButton(
              icon: Icons.emoji_emotions_outlined,
              tooltip: 'Project Status Stickers',
              onTap: () {
                StickerPickerSheet.show(
                  context,
                  onStickerSelected: (sticker) {
                    final size = MediaQuery.of(context).size;
                    context.read<CanvasCubit>().addSticker(sticker, size);
                  },
                );
              },
            ),
            const SizedBox(width: 8),

            // Freehand brush tool
            _buildCircleIconButton(
              icon: Icons.brush,
              tooltip: 'Draw',
              onTap: () {
                context.read<CanvasCubit>().setTool(CanvasTool.brush);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomShareBar(BuildContext context, CanvasState state) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black87, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Save locally button
          InkWell(
            onTap: _handleSaveExportOnly,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.download, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // DIRECT TO INSTAGRAM STORIES BUTTON
          GestureDetector(
            onTap: _handleShareToInstagramStory,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: AppColors.instagramGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66E1306C),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.instagramPink,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Your Story',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }
}
