import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/caption_model.dart';

class InteractiveCaptionWidget extends StatefulWidget {
  final CaptionModel caption;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final void Function(Offset position, double scale, double rotation)
      onTransformUpdate;

  const InteractiveCaptionWidget({
    super.key,
    required this.caption,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onTransformUpdate,
  });

  @override
  State<InteractiveCaptionWidget> createState() =>
      _InteractiveCaptionWidgetState();
}

class _InteractiveCaptionWidgetState extends State<InteractiveCaptionWidget> {
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
    _position = widget.caption.position;
    _scale = widget.caption.scale;
    _rotation = widget.caption.rotation;
  }

  @override
  void didUpdateWidget(covariant InteractiveCaptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.caption.position != oldWidget.caption.position ||
        widget.caption.scale != oldWidget.caption.scale ||
        widget.caption.rotation != oldWidget.caption.rotation) {
      _position = widget.caption.position;
      _scale = widget.caption.scale;
      _rotation = widget.caption.rotation;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.caption.fontStyle) {
      case CaptionFontStyle.modern:
        return GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: widget.caption.textColor,
        );
      case CaptionFontStyle.classic:
        return GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: widget.caption.textColor,
        );
      case CaptionFontStyle.neon:
        return GoogleFonts.vt323(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: widget.caption.textColor,
          shadows: [
            Shadow(
              color: widget.caption.textColor.withValues(alpha: 0.8),
              blurRadius: 10,
            ),
          ],
        );
      case CaptionFontStyle.typewriter:
        return GoogleFonts.courierPrime(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: widget.caption.textColor,
        );
      case CaptionFontStyle.strong:
        return GoogleFonts.bebasNeue(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: widget.caption.textColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx - 150,
      top: _position.dy - 40,
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
              math.max(0.4, math.min(3.0, _startScale * details.scale));
          final newRotation = _startRotation + details.rotation;

          setState(() {
            _position = newPosition;
            _scale = newScale;
            _rotation = newRotation;
          });

          widget.onTransformUpdate(newPosition, newScale, newRotation);
        },
        child: SizedBox(
          width: 300,
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(_scale, _scale, 1.0)
                ..rotateZ(_rotation),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.caption.hasBackground
                          ? widget.caption.backgroundColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: widget.isSelected
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Text(
                      widget.caption.text,
                      textAlign: TextAlign.center,
                      style: _getTextStyle(),
                    ),
                  ),

                  // Delete button when selected
                  if (widget.isSelected)
                    Positioned(
                      top: -10,
                      right: -10,
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          width: 24,
                          height: 24,
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
                            size: 14,
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
