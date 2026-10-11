import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/caption_model.dart';

class CaptionInputDialog extends StatefulWidget {
  final CaptionModel? initialCaption;
  final ValueChanged<CaptionModel> onDone;

  const CaptionInputDialog({
    super.key,
    this.initialCaption,
    required this.onDone,
  });

  static Future<void> show(
    BuildContext context, {
    CaptionModel? initialCaption,
    required ValueChanged<CaptionModel> onDone,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CaptionDialog',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) => CaptionInputDialog(
        initialCaption: initialCaption,
        onDone: onDone,
      ),
    );
  }

  @override
  State<CaptionInputDialog> createState() => _CaptionInputDialogState();
}

class _CaptionInputDialogState extends State<CaptionInputDialog> {
  late TextEditingController _textController;
  late CaptionFontStyle _fontStyle;
  late bool _hasBackground;
  late Color _textColor;

  final List<Color> _textColors = [
    Colors.white,
    Colors.black,
    Color(0xFFFF2A6D),
    Color(0xFFFFD600),
    Color(0xFF00E676),
    Color(0xFF00E5FF),
    Color(0xFF8E24AA),
    Color(0xFFFF6F00),
  ];

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.initialCaption?.text ?? '');
    _fontStyle = widget.initialCaption?.fontStyle ?? CaptionFontStyle.modern;
    _hasBackground = widget.initialCaption?.hasBackground ?? true;
    _textColor = widget.initialCaption?.textColor ?? Colors.white;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _cycleFontStyle() {
    final values = CaptionFontStyle.values;
    final nextIndex = (values.indexOf(_fontStyle) + 1) % values.length;
    setState(() {
      _fontStyle = values[nextIndex];
    });
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final caption = CaptionModel(
      id: widget.initialCaption?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      textColor: _textColor,
      hasBackground: _hasBackground,
      backgroundColor: _textColor == Colors.black ? Colors.white : Colors.black87,
      position: widget.initialCaption?.position ??
          Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height / 2,
          ),
      scale: widget.initialCaption?.scale ?? 1.0,
      rotation: widget.initialCaption?.rotation ?? 0.0,
      fontStyle: _fontStyle,
    );

    widget.onDone(caption);
    Navigator.of(context).pop();
  }

  TextStyle _getCurrentTextStyle() {
    switch (_fontStyle) {
      case CaptionFontStyle.modern:
        return GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: _textColor,
        );
      case CaptionFontStyle.classic:
        return GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: _textColor,
        );
      case CaptionFontStyle.neon:
        return GoogleFonts.vt323(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: _textColor,
          shadows: [
            Shadow(
              color: _textColor.withValues(alpha: 0.8),
              blurRadius: 12,
            ),
          ],
        );
      case CaptionFontStyle.typewriter:
        return GoogleFonts.courierPrime(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _textColor,
        );
      case CaptionFontStyle.strong:
        return GoogleFonts.bebasNeue(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: _textColor,
        );
    }
  }

  String _getFontLabel() {
    switch (_fontStyle) {
      case CaptionFontStyle.modern:
        return 'MODERN';
      case CaptionFontStyle.classic:
        return 'CLASSIC';
      case CaptionFontStyle.neon:
        return 'NEON';
      case CaptionFontStyle.typewriter:
        return 'TYPEWRITER';
      case CaptionFontStyle.strong:
        return 'STRONG';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Font style switcher
                  GestureDetector(
                    onTap: _cycleFontStyle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getFontLabel(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Background highlight toggle button
                  IconButton(
                    icon: Icon(
                      _hasBackground
                          ? Icons.format_color_fill
                          : Icons.format_color_reset,
                      color: _hasBackground ? Colors.amber : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _hasBackground = !_hasBackground;
                      });
                    },
                  ),

                  const Spacer(),

                  // Done button
                  TextButton(
                    onPressed: _submit,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text input centered
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _hasBackground
                          ? (_textColor == Colors.black
                              ? Colors.white
                              : Colors.black87)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _textController,
                      autofocus: true,
                      maxLines: null,
                      textAlign: TextAlign.center,
                      style: _getCurrentTextStyle(),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a caption...',
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Color palette bar
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _textColors.length,
                  itemBuilder: (context, index) {
                    final color = _textColors[index];
                    final isSelected = color == _textColor;
                    return GestureDetector(
                      onTap: () => setState(() => _textColor = color),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white24,
                            width: isSelected ? 3.5 : 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
