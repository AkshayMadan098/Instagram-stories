import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/sticker_item.dart';
import '../../../stickers/presentation/widgets/sticker_badge_widget.dart';

class InteractiveStickerWidget extends StatefulWidget {
  final StickerItem stickerItem;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final void Function(Offset position, double scale, double rotation)
      onTransformUpdate;

  const InteractiveStickerWidget({
    super.key,
    required this.stickerItem,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onTransformUpdate,
  });

  @override
  State<InteractiveStickerWidget> createState() =>
      _InteractiveStickerWidgetState();
}

class _InteractiveStickerWidgetState extends State<InteractiveStickerWidget> {
  late Offset _position;
  late double _scale;
  late double _rotation;

  Offset _startFocalPoint = Offset.zero;
  Offset _startPosition = Offset.zero;
  double _startScale = 1.0;
  double _startRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _position = widget.stickerItem.position;
    _scale = widget.stickerItem.scale;
    _rotation = widget.stickerItem.rotation;
  }

  @override
  void didUpdateWidget(covariant InteractiveStickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stickerItem.position != oldWidget.stickerItem.position ||
        widget.stickerItem.scale != oldWidget.stickerItem.scale ||
        widget.stickerItem.rotation != oldWidget.stickerItem.rotation) {
      _position = widget.stickerItem.position;
      _scale = widget.stickerItem.scale;
      _rotation = widget.stickerItem.rotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx - 100,
      top: _position.dy - 50,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onScaleStart: (details) {
          widget.onTap();
          _startFocalPoint = details.focalPoint;
          _startPosition = _position;
          _startScale = _scale;
          _startRotation = _rotation;
        },
        onScaleUpdate: (details) {
          final delta = details.focalPoint - _startFocalPoint;
          final newPosition = _startPosition + delta;
          final newScale =
              math.max(0.4, math.min(3.5, _startScale * details.scale));
          final newRotation = _startRotation + details.rotation;

          setState(() {
            _position = newPosition;
            _scale = newScale;
            _rotation = newRotation;
          });

          widget.onTransformUpdate(newPosition, newScale, newRotation);
        },
        child: SizedBox(
          width: 200,
          height: 100,
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(_scale, _scale, 1.0)
                ..rotateZ(_rotation),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Sticker body with optional selection border
                  Container(
                    decoration: widget.isSelected
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                          )
                        : null,
                    padding: widget.isSelected
                        ? const EdgeInsets.all(6)
                        : EdgeInsets.zero,
                    child: StickerBadgeWidget(
                      sticker: widget.stickerItem.definition,
                    ),
                  ),

                  // Delete button when selected
                  if (widget.isSelected)
                    Positioned(
                      top: -12,
                      right: -12,
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
