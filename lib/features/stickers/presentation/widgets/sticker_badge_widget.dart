import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/sticker_definition.dart';

class StickerBadgeWidget extends StatelessWidget {
  final StickerDefinition sticker;
  final double scale;

  const StickerBadgeWidget({
    super.key,
    required this.sticker,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: _buildShapeBadge(),
    );
  }

  Widget _buildShapeBadge() {
    switch (sticker.shape) {
      case StickerBadgeShape.speechBubble:
        return _buildSpeechBubble();
      case StickerBadgeShape.starburst:
        return _buildStarburst();
      case StickerBadgeShape.flame:
        return _buildFlame();
      case StickerBadgeShape.stamp:
        return _buildStamp();
      case StickerBadgeShape.warningTape:
        return _buildWarningTape();
      case StickerBadgeShape.shield:
        return _buildShield();
      case StickerBadgeShape.pill:
      case StickerBadgeShape.roundedRect:
        return _buildPillOrRoundedRect();
    }
  }

  Widget _buildSpeechBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: sticker.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(
          color: sticker.strokeColor,
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildStarburst() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sticker.primaryColor, sticker.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sticker.strokeColor,
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(4, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: _buildContent(letterSpacing: 1.5),
    );
  }

  Widget _buildFlame() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sticker.primaryColor, sticker.secondaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white,
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildStamp() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: sticker.primaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: sticker.strokeColor,
          width: 3.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            offset: Offset(2, 3),
            blurRadius: 2,
          ),
        ],
      ),
      child: _buildContent(letterSpacing: 2.0),
    );
  }

  Widget _buildWarningTape() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: sticker.primaryColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black,
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildShield() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: sticker.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border.all(
          color: sticker.strokeColor,
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildPillOrRoundedRect() {
    final bool isPill = sticker.shape == StickerBadgeShape.pill;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [sticker.primaryColor, sticker.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isPill ? 30 : 12),
        border: Border.all(
          color: sticker.strokeColor,
          width: 3.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            offset: Offset(3, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent({double letterSpacing = 1.0}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (sticker.emoji != null) ...[
          Text(
            sticker.emoji!,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
        ] else if (sticker.icon != null) ...[
          Icon(
            sticker.icon,
            size: 20,
            color: sticker.textColor,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          sticker.text,
          style: GoogleFonts.rubik(
            color: sticker.textColor,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: letterSpacing,
          ),
        ),
      ],
    );
  }
}
